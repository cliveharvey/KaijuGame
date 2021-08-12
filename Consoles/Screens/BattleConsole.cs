using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Console = SadConsole.Console;
using System.Threading.Tasks;
using KaijuGame.Entities;

namespace KaijuGame.Consoles.Screens
{
    internal class BattleConsole : Console
    {
        public BattleConsole() : base(80, 25)
        {
            var squad = MakeSquad();
            var kaiju = MakeKaiju();
            var success = squad.SquadCombat(kaiju.Difficulty);
        }

        private Squad MakeSquad()
        {
            var soldiers = new List<Soldier>();
            var r = new Random();

            for (int x = 0; x < 5; x++)
            {
                var soldier = new Soldier(r.Next(3, 8), r.Next(14, 40));
                soldiers.Add(soldier);
            }
            return new Squad("Boom Boom Shoe Makers", soldiers);
        }

        private Kaiju MakeKaiju()
        {
            var r = new Random();
            var kaiju = new Kaiju(r.Next(3), r.Next(10, 30));
            return kaiju;
        }
    }
}
