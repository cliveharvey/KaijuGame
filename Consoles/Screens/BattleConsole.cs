using System;
using System.Collections.Generic;
using SadConsole;
using SadRogue.Primitives;
using Console = SadConsole.Console;
using KaijuGame.Entities;
using KaijuGame.TextDump;

using SadConsole.UI.Controls;
using SadConsole.UI.Themes;
using KaijuGame.Helpers;

namespace KaijuGame.Consoles.Screens
{
    internal class BattleConsole : Console
    {
        public Action ExtractTeam { get; set; }
        public Kaiju Kaiju { get; set; }

        private Console missionStatusView;
        private Console userActionView;
        public BattleConsole(Kaiju kaiju) : base(80, 31)
        {
            Kaiju = kaiju;
            SetupViews();
        }

        private void SetupViews()
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
            userActionView.Children.Add(new ExtractTeamConsole() { ExtractButton = ExtractTheTeam, BattleConsole = this });
        }


        public void SendThemIn(Console missionStatusView) {
            var squad = MakeSquad();
            var kaiju = Kaiju;
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
                BattleText(createdText, squad, kaiju);

                var text = createdText.ToArray();

                typingInstruction = new SadConsole.Instructions.DrawString(SadConsole.ColoredString.Parse(string.Join("\r\n", text)));
                typingInstruction.TotalTimeToPrint = 14; // 0.25 seconds per line of text
                Cursor.Position = new Point(1, 1);
                Cursor.IsEnabled = true;
                Cursor.IsVisible = true;
                typingInstruction.Cursor = Cursor;
                SadComponents.Add(typingInstruction);
            }

            private void BattleText(List<string> text, Squad squad, Kaiju kaiju)
            {
                text.Add($"[c:r f:Yellow]\"{ kaiju.nameEnglish}\" [c:r f:white]the {kaiju.Size} {kaiju.creature} has made landfall!");
                var success = squad.SquadCombat(kaiju.Difficulty);
                var battleText = new BattleText();
                foreach (var member in squad.Members)
                {
                    battleText.BatteTextSummary(text, member);
                    if (member.Status != 0)
                    {
                        text.Add("[c:r f:white]Squad Member [c:r f:Yellow]" + member.Name + " [c:r f:white]was " + EnumHelper.GetDescription(member.Status));
                    }
                    text.Add("");
                }

                if (success)
                {
                    text.Add("[c:r f:Green]The Mission was Successful!");
                }
                else
                {
                    text.Add("[c:r f:Red]Mission Failed");
                }

            }
        }

        internal class ExtractTeamConsole : SadConsole.UI.ControlsConsole
        {
            public Action ExtractButton { get; set; }
            public BattleConsole BattleConsole { get; set; }
            public ExtractTeamConsole() : base(80, 15)
            {
                var button1 = new Button(20, 3)
                {
                    Text = "Send Them In!",
                    Position = new Point(1, 0),
                    Theme = new ButtonLinesTheme()
                };
                button1.Click += (s, a) => { BattleConsole.SendThemIn(BattleConsole.missionStatusView); Controls.Remove(button1); };
                Controls.Add(button1);

                var button2 = new Button(20, 3)
                {
                    Text = "Extract Troops",
                    Position = new Point(1, 3),
                    Theme = new ButtonLinesTheme()
                };
                button2.Click += (s, a) => { ExtractButton?.Invoke(); BattleConsole.SetupViews(); };
                Controls.Add(button2);


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
    }
}
