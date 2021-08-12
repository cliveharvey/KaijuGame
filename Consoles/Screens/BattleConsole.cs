using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SadConsole;
using SadRogue.Primitives;
using Console = SadConsole.Console;
using System.Threading.Tasks;
using KaijuGame.Entities;
using SadConsole.UI.Controls;
using SadConsole.UI.Themes;

namespace KaijuGame.Consoles.Screens
{
    internal class BattleConsole : Console
    {
        public Action ExtractTeam { get; set; }


        private readonly Console missionStatusView;
        private readonly Console userActionView;
        public BattleConsole() : base(80, 25)
        {
            missionStatusView = new Console(80, 15);
            userActionView = new Console(80, 10);

            missionStatusView.Fill(Color.White, Color.Green, 0);
            userActionView.Fill(Color.White, Color.Blue, 0);

            UseMouse = true;

            // Add the consoles to the list.
            Children.Add(missionStatusView);
            Children.Add(userActionView);


            // Setup main view
            missionStatusView.Position = new Point(0, 0);

            // Setup sub view
            userActionView.Position = new Point(0, 16);
            userActionView.Children.Add(new ExtractTeamConsole() { ExtractButton = ExtractTheTeam, BattleConsole=this });

        }

        public void SendThemIn(Console missionStatusView) {
            var squad = MakeSquad();
            var kaiju = MakeKaiju();
            missionStatusView.DefaultBackground = Color.Green;
            missionStatusView.Clear();
            missionStatusView.Children.Add(new BattleSummaryConsole(squad, kaiju));
        }

        public void ExtractTheTeam()
        {
            ExtractTeam?.Invoke();
        }

        internal class BattleSummaryConsole : Console
        {
            SadConsole.Instructions.DrawString typingInstruction;
            public BattleSummaryConsole(Squad squad, Kaiju kaiju) : base(80, 15)
            {
                List<string> createdText = new List<string>();
                createdText.Add("The " + kaiju.Size + " Kaiju has made landfall!");
                var success = squad.SquadCombat(kaiju.Difficulty);
                foreach (var member in squad.Members)
                {
                    if (member.Status != 0)
                    {
                        createdText.Add("Squad Member " + member.Name + " was " + member.Status);
                    }
                    else
                    {
                        createdText.Add("Squad Member " + member.Name + " was unhurt");
                    }
                }

                if (success)
                {
                    createdText.Add("The Mission was Successful!");
                }
                else
                {
                    createdText.Add("Mission Failed");
                }

                var text = createdText.ToArray();

                typingInstruction = new SadConsole.Instructions.DrawString(SadConsole.ColoredString.Parse(string.Join("\r\n", text)));
                typingInstruction.TotalTimeToPrint = 7; // 0.25 seconds per line of text
                Cursor.Position = new Point(1, 1);
                Cursor.IsEnabled = false;
                Cursor.IsVisible = true;
                typingInstruction.Cursor = Cursor;
                SadComponents.Add(typingInstruction);
            }
        }

        internal class ExtractTeamConsole : SadConsole.UI.ControlsConsole
        {
            public Action ExtractButton { get; set; }
            public BattleConsole BattleConsole { get; set; }
            public ExtractTeamConsole() : base(80, 15)
            {
                var button = new Button(20, 3)
                {
                    Text = "Send Them In!",
                    Position = new Point(1, 0),
                    Theme = new ButtonLinesTheme()
                };
                button.Click += (s, a) => { BattleConsole.SendThemIn(BattleConsole.missionStatusView); };
                Controls.Add(button);

                button = new Button(20, 3)
                {
                    Text = "Extract Troops",
                    Position = new Point(1, 3),
                    Theme = new ButtonLinesTheme()
                };
                button.Click += (s, a) => { ExtractButton?.Invoke(); };
                Controls.Add(button);


            }
        }

        private Squad MakeSquad()
        {
            var soldiers = new List<Soldier>();
            var r = new Random();

            for (int x = 0; x < 5; x++)
            {
                var soldier = new Soldier(r.Next(3, 8), r.Next(10, 35));
                soldiers.Add(soldier);
            }
            return new Squad("Boom Boom Shoe Makers", soldiers);
        }

        private Kaiju MakeKaiju()
        {
            var r = new Random();
            var kSize = r.Next(3);
            var kDif = (kSize + 1) * 10;
            var kaiju = new Kaiju(kSize, r.Next(kDif, kDif+10));
            return kaiju;
        }
    }
}
