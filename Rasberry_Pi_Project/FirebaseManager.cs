using System;
using System.Threading.Tasks;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Google.Cloud.Firestore;

namespace RFID_Project
{
    public class FirebaseManager
    {
        // 외부에서 접근 가능한 Db 프로퍼티
        public FirestoreDb Db { get; private set; }

        public FirebaseManager(string jsonPath, string projectId)
        {
            GoogleCredential credential = GoogleCredential.FromFile(jsonPath);

            if (FirebaseApp.DefaultInstance == null)
            {
                FirebaseApp.Create(new AppOptions()
                {
                    Credential = credential
                });
            }

            FirestoreDbBuilder builder = new FirestoreDbBuilder
            {
                ProjectId = projectId,
                Credential = credential
            };
            
            // 핵심: 인증 정보가 포함된 DB 인스턴스를 Db 프로퍼티에 할당
            Db = builder.Build();
            
            Console.WriteLine("Firebase Firestore 연결 성공!");
        }

        public void ListenToModeChange(Action<string> onModeChanged)
        {
            DocumentReference docRef = Db.Collection("system_control").Document("rpi_01");

            docRef.Listen(snapshot =>
            {
                if (snapshot.Exists)
                {
                    string newMode = snapshot.GetValue<string>("mode");
                    Console.WriteLine($"[알림] Firebase 모드 변경 감지: {newMode}");
                    onModeChanged?.Invoke(newMode);
                }
            });
        }

        public async Task UploadTagData(string epc)
        {
            try
            {
                CollectionReference collection = Db.Collection("Tags");
                var data = new { TagID = epc, Timestamp = FieldValue.ServerTimestamp, Status = "Detected" };
                await collection.AddAsync(data);
                Console.WriteLine($"[Firebase 업로드 완료]: {epc}");
            }
            catch (Exception ex) { Console.WriteLine($"업로드 실패: {ex.Message}"); }
        }
    }
}