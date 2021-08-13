using System;
using Console = SadConsole.Console;
using SadConsole;
using SadRogue.Primitives;
using SadConsole.UI.Controls;
using SadConsole.UI.Themes;
using KaijuGame.Entities;


namespace KaijuGame.Consoles.Screens
{
    internal class MissionConsole : Console
    {
        public Action DeployTeam { get; set; }

        private Console missionBriefView;
        private Console userActionView;
        public Kaiju Kaiju { get; set; }

        public MissionConsole(Kaiju kaiju) : base(80, 31)
        {
            Kaiju = kaiju;
            SetupViews();
        }

        public void SetupViews()
        {
            missionBriefView = new Console(80, 15);
            userActionView = new Console(80, 10);

            missionBriefView.Fill(Color.White, Color.Red, 0);
            userActionView.Fill(Color.White, Color.Blue, 0);

            UseMouse = true;

            // Add the consoles to the list.
            Children.Add(missionBriefView);
            Children.Add(userActionView);

            // Setup main view
            missionBriefView.Position = new Point(0, 0);

            // Setup sub view
            userActionView.Position = new Point(0, 16);

            missionBriefView.Children.Add(new WritingConsole(Kaiju));
            userActionView.Children.Add(new DeployTeamConsole() { DeployButton = DeployTheTeam });

            IsVisible = false;
        }

        public void DeployTheTeam()
        {
            DeployTeam?.Invoke();
            Children.Clear();
            missionBriefView.DefaultBackground = Color.Red;
            missionBriefView.Clear();
            SetupViews();
        }
    }

    internal class DeployTeamConsole : SadConsole.UI.ControlsConsole
    {
        public Action DeployButton { get; set; }
        public DeployTeamConsole() : base(80, 15)
        {
            var button = new Button(20, 3)
            {
                Text = "Deploy Troops",
                Position = new Point(1, 0),
                Theme = new ButtonLinesTheme()
            };
            button.Click += (s, a) => { DeployButton?.Invoke(); };
            Controls.Add(button);

            button = new Button(20, 3)
            {
                Text = "Lets stay home",
                Position = new Point(1, 3),
                Theme = new ButtonLinesTheme()
            };
            button.Click += (s, a) => SadConsole.UI.Window.Message("This is what you're paid for soldier, now do your duty!", "Close");
            Controls.Add(button);
        }
    }

    internal class WritingConsole : Console
    {
        SadConsole.Instructions.DrawString typingInstruction;
        public WritingConsole(Kaiju monster) : base(80, 15)
        {
            var location = new Location();
            string[] text = new string[]
            {
                "A terrifying new breed of Kaiju has been spotted terrorizing " + location.City + "!",
                "It has already toppled the CN tower, and is making its way towards the Clio office!",
            };

            string[] text2 = new string[]
            {
                $"The Kaiju \"{monster.nameEnglish}\" has begun its attack on {location.City}",
                $"Resembling a {monster.Size} {monster.creature} with {monster.characteristic}, the {monster.material} beast",
                $"attacks buildings with its {monster.weapon}! Beware!",
            };

            typingInstruction = new SadConsole.Instructions.DrawString(SadConsole.ColoredString.Parse(string.Join("\r\n", text2)));
            typingInstruction.TotalTimeToPrint = 7; // 0.25 seconds per line of text
            Cursor.Position = new Point(1, 1);
            Cursor.IsEnabled = false;
            Cursor.IsVisible = true;
            typingInstruction.Cursor = Cursor;
            SadComponents.Add(typingInstruction);
        }
    }
}
