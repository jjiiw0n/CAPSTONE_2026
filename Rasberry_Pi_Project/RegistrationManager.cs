// 물품 등록모드 알고리즘
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Google.Cloud.Firestore;

namespace RFID_Project
{
    public class RegistrationManager
    {
        private readonly FirestoreDb _db;
        private readonly LcdManager _lcd;
        private readonly LocalTagChecker _tagChecker;
        private bool _hasSentToBuffer = false;

        public RegistrationManager(FirestoreDb db, LcdManager lcd, LocalTagChecker tagChecker)
        {
            _db = db;
            _lcd = lcd;
            _tagChecker = tagChecker;
        }

        public async Task ProcessRegistration(List<string> scannedEpcs)
        {
            if (_hasSentToBuffer) return;

            List<string> newTags = scannedEpcs
                .Where(epc => _tagChecker.IsNewTag(epc))
                .Distinct()
                .ToList();

            if (newTags.Count == 0) return;

            if (newTags.Count == 1)
            {
                string targetEpc = newTags[0];
                try {
                    DocumentReference bufferRef = _db.Collection("system_control").Document("Tag_ID");
                    await bufferRef.UpdateAsync("new", targetEpc);
                    _hasSentToBuffer = true;
                    _lcd.UpdateDisplay("REG-READY", targetEpc);
                    Console.WriteLine($">>> [완료] 버퍼 전송 성공: {targetEpc}");
                } catch (Exception ex) { Console.WriteLine($"전송 실패: {ex.Message}"); }
            }
            else
            {
                _lcd.UpdateDisplay("TOO MANY", $"COUNT: {newTags.Count}");
            }
        }

        public async Task ResetRegistrationSession()
        {
            _hasSentToBuffer = false;
            try {
                DocumentReference bufferRef = _db.Collection("system_control").Document("Tag_ID");
                await bufferRef.UpdateAsync("new", "ID");
                Console.WriteLine("[시스템] 등록 버퍼 리셋 완료.");
            } catch (Exception ex) { Console.WriteLine($"리셋 실패: {ex.Message}"); }
        }
    }
}