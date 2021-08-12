using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KaijuGame.Entities
{
    enum SoldierStatus
    {
        Alive,
        Skratched,
        Injured,
        KIA
    }
    class Soldier
    {
        private string name;
        private int skill;
        private SoldierStatus status;

        public Soldier(string soldierName, int soldierSkill) {
            name = soldierName;
            skill = soldierSkill;
            status = SoldierStatus.Alive;
        }

        public Soldier(int nameLength, int soldierSkill)
        {
            name = GenerateName(nameLength);
            skill = soldierSkill;
            status = SoldierStatus.Alive;
        }

        public string Name
        {
            get => name;
            set => name = value;
        }

        public int Skill
        {
            get => skill;
            set => skill = value;
        }

        public SoldierStatus Status
        {
            get => status;
            set => status = value;
        }

        public bool Combat (int difficulty)
        {
            //Makes a combat roll based on soldiers skill. 
            var combatRoll = new Random().Next(Skill);
            //Soldiers Status changes based on combat roll
            if (combatRoll < difficulty - 30)
            {
                Status = SoldierStatus.KIA;
                return false;
            }
            else if (combatRoll < difficulty - 20)
            {
                Status = SoldierStatus.Injured;
                return false;
            }
            else if (combatRoll < difficulty - 10)
            {
                Status = SoldierStatus.Skratched;
            }
            return true;
        }

        public static string GenerateName(int len)
        {
            Random r = new Random();
            string[] consonants = { "b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "l", "n", "p", "q", "r", "s", "sh", "zh", "t", "v", "w", "x" };
            string[] vowels = { "a", "e", "i", "o", "u", "ae", "y" };
            string Name = "";
            Name += consonants[r.Next(consonants.Length)].ToUpper();
            Name += vowels[r.Next(vowels.Length)];
            int b = 2; //b tells how many times a new letter has been added. It's 2 right now because the first two letters are already in the name.
            while (b < len)
            {
                Name += consonants[r.Next(consonants.Length)];
                b++;
                Name += vowels[r.Next(vowels.Length)];
                b++;
            }

            return Name;


        }
    }
}
