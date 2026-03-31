using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using Google.Cloud.Firestore;

namespace RFID_Project
{
    public class TagDatabase
    {
        public DateTime UpdatedAt { get; set; }
        public List<string> TagList { get; set; } = new List<string>();
    }

    public class LocalTagChecker
    {
        private readonly string _filePath = "tags_db.json";
        private readonly FirestoreDb _db;
        private Dictionary<string, int> _tagRefCount = new Dictionary<string, int>();
        private Dictionary<string, List<string>?> _categoryOldState = new Dictionary<string, List<string>?>();
        private Dictionary<string, string?> _calendarOldState = new Dictionary<string, string?>();

        public LocalTagChecker(FirestoreDb db)
        {
            _db = db;
            LoadFromJson();
            StartIncrementalSync();
        }

        private void StartIncrementalSync()
        {
            _db.Collection("calendar").Listen(snapshot =>
            {
                foreach (DocumentChange change in snapshot.Changes)
                {
                    string docId = change.Document.Id;
                    string? newTag = change.Document.ContainsField("TagID") ? change.Document.GetValue<string>("TagID") : null;

                    if (change.ChangeType == DocumentChange.Type.Added || change.ChangeType == DocumentChange.Type.Modified)
                    {
                        if (_calendarOldState.TryGetValue(docId, out string? oldTag)) UpdateRefCount(oldTag, -1);
                        if (!string.IsNullOrEmpty(newTag)) { UpdateRefCount(newTag, 1); _calendarOldState[docId] = newTag; }
                    }
                    else if (change.ChangeType == DocumentChange.Type.Removed)
                    {
                        if (_calendarOldState.TryGetValue(docId, out string? oldTag)) { UpdateRefCount(oldTag, -1); _calendarOldState.Remove(docId); }
                    }
                }
                SaveToJson();
            });

            _db.Collection("categories").Listen(snapshot =>
            {
                foreach (DocumentChange change in snapshot.Changes)
                {
                    string catName = change.Document.Id;
                    List<string> newTags = change.Document.ContainsField("TagID") ? change.Document.GetValue<List<string>>("TagID") : new List<string>();

                    if (change.ChangeType == DocumentChange.Type.Added || change.ChangeType == DocumentChange.Type.Modified)
                    {
                        _categoryOldState.TryGetValue(catName, out List<string>? oldTags);
                        oldTags ??= new List<string>();
                        var added = newTags.Except(oldTags).ToList();
                        var removed = oldTags.Except(newTags).ToList();
                        foreach (var t in added) UpdateRefCount(t, 1);
                        foreach (var t in removed) UpdateRefCount(t, -1);
                        _categoryOldState[catName] = newTags;
                    }
                    else if (change.ChangeType == DocumentChange.Type.Removed)
                    {
                        if (_categoryOldState.TryGetValue(catName, out List<string>? oldTags))
                        {
                            if (oldTags != null) foreach (var t in oldTags) UpdateRefCount(t, -1);
                            _categoryOldState.Remove(catName);
                        }
                    }
                }
                SaveToJson();
            });
        }

        private void UpdateRefCount(string? tagId, int delta)
        {
            if (string.IsNullOrEmpty(tagId)) return;
            lock (_tagRefCount)
            {
                if (!_tagRefCount.ContainsKey(tagId)) _tagRefCount[tagId] = 0;
                _tagRefCount[tagId] += delta;
                if (_tagRefCount[tagId] <= 0) _tagRefCount.Remove(tagId);
            }
        }

        private void SaveToJson()
        {
            lock (_tagRefCount)
            {
                var dbSnapshot = new TagDatabase { UpdatedAt = DateTime.Now, TagList = _tagRefCount.Keys.ToList() };
                File.WriteAllText(_filePath, JsonSerializer.Serialize(dbSnapshot, new JsonSerializerOptions { WriteIndented = true }));
            }
        }

        private void LoadFromJson()
        {
            if (File.Exists(_filePath))
            {
                try {
                    var db = JsonSerializer.Deserialize<TagDatabase>(File.ReadAllText(_filePath));
                    if (db != null) foreach (var tag in db.TagList) _tagRefCount[tag] = 1;
                } catch { }
            }
        }

        public bool IsNewTag(string epc) { lock (_tagRefCount) return !_tagRefCount.ContainsKey(epc); }
    }
}