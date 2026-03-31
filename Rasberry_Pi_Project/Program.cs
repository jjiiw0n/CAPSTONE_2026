using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Reader;
using RFID_Project;

class Program
{
    static async Task Main(string[] args)
    {
        ReaderMethod reader = new ReaderMethod();
        FirebaseManager firebase = new FirebaseManager("service-account.json", "capstone-cb429");
        LcdManager lcd = new LcdManager();
        
        LocalTagChecker tagChecker = new LocalTagChecker(firebase.Db); 
        RegistrationManager regManager = new RegistrationManager(firebase.Db, lcd, tagChecker);

        string currentEpc = "None";   
        string currentMode = "normal"; 

        firebase.ListenToModeChange(async (newMode) => 
        {
            currentMode = newMode;
            Console.WriteLine($"\n[시스템] 모드 전환: {currentMode.ToUpper()}");
            
            if (currentMode == "normal")
            {
                await regManager.ResetRegistrationSession();
            }
            lcd.UpdateDisplay(currentMode, "SYSTEM READY");
        });

        reader.AnalyCallback = async (msg) => 
        {
            if (msg.Cmd == 0x89) 
            {
                currentEpc = BitConverter.ToString(msg.AryData);
                
                if (currentMode == "registration") 
                {
                    await regManager.ProcessRegistration(new List<string> { currentEpc });
                }
                else 
                {
                    bool isRegistered = !tagChecker.IsNewTag(currentEpc);
                    lcd.UpdateDisplay(currentMode, currentEpc);
                    Console.WriteLine($"[감지] {currentEpc} ({(isRegistered ? "등록됨" : "미등록")})");
                }
            }
        };

        string exception;
        int result = reader.OpenCom("COM3", 115200, out exception);

        if (result == 0) 
        {
            Console.WriteLine("리더기 연결 성공!");
            reader.InventoryReal(0xFF, 0xFF);
        } 
        else 
        {
            Console.WriteLine("리더기 연결 실패. 가상 모드 시작.");
            StartMockReader(regManager); 
        }

        while(true) { await Task.Delay(1000); }
    }

    static void StartMockReader(RegistrationManager regManager)
    {
        Thread mockThread = new Thread(async () => {
            string[] fakeEpcs = { "E2-80-11-91", "E2-00-00-15", "AA-BB-CC-DD" };
            Random rand = new Random();
            while (true) {
                await Task.Delay(3000);
                string selectedEpc = fakeEpcs[rand.Next(fakeEpcs.Length)];
                await regManager.ProcessRegistration(new List<string> { selectedEpc });
            }
        });
        mockThread.IsBackground = true;
        mockThread.Start();
    }
}