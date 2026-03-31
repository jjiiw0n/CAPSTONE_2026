using System;

namespace RFID_Project
{
    public class LcdManager
    {
        // 실제 라즈베리파이에서는 I2cDevice 등을 사용하지만, 
        // 지금은 시뮬레이션을 위해 콘솔 출력을 사용합니다.
        
        public void UpdateDisplay(string mode, string lastTag)
        {
            Console.WriteLine("\n============================");
            Console.WriteLine($"[ 가상 LCD 화면 (16x2) ]");
            Console.WriteLine($"LINE 1: MODE: {mode.ToUpper()}");
            
            // 태그 ID가 너무 길면 잘라서 표시 (LCD는 칸이 좁으니까요)
            string displayTag = lastTag.Length > 10 ? lastTag.Substring(0, 10) + ".." : lastTag;
            Console.WriteLine($"LINE 2: ID: {displayTag}");
            Console.WriteLine("============================\n");
        }

        public void ShowMessage(string line1, string line2)
        {
            Console.WriteLine("\n----------------------------");
            Console.WriteLine($"L1: {line1}");
            Console.WriteLine($"L2: {line2}");
            Console.WriteLine("----------------------------\n");
        }
    }
}