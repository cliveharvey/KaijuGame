using KaijuGame.Consoles.Screens;
using KaijuGame.Entities;
using SadConsole;

namespace KaijuGame.Consoles
{
    class Container : ScreenObject
    {
        private int currentConsoleIndex = -1;
        private IScreenObject selectedConsole;
        private HeaderConsole headerConsole;
        private ScreenObject selectedConsoleContainer;

        CustomConsole[] consoles;

        public Container()
        {
            headerConsole = new HeaderConsole();
            selectedConsoleContainer = new ScreenObject();
            selectedConsoleContainer.Position = (0, headerConsole.AbsoluteArea.MaxExtentY + 1);

            var _kaiju = KaijuGenerator.makeKaiju();

            consoles = new CustomConsole[]
            {
                new CustomConsole(new MainScreenConsole(), "Main Screen", "Beep Boop" ),
                new CustomConsole(new BaseConsole(){KaijuAttack = MoveNextConsole }, "Main Base", "Current Base Status" ),
                new CustomConsole(new MissionConsole(_kaiju){DeployTeam = MoveNextConsole }, "Mission Summary", "The reports are coming in!" ),
                new CustomConsole(new BattleConsole(_kaiju){ExtractTeam = MoveNextConsole }, "Battle Report", "Beep Boop" ),
                new CustomConsole(new RewardConsole(), "Rewards", "Beep Boop" )
            };

            MoveNextConsole();
        }

        Kaiju missionKaiju;
        Kaiju battleKaiju;
        public void MoveNextConsole()
        {
            currentConsoleIndex++;

            if (currentConsoleIndex >= consoles.Length)
                currentConsoleIndex = 0;

            selectedConsole = consoles[currentConsoleIndex].Console;

            Children.Clear();
            Children.Add(headerConsole);
            Children.Add(selectedConsoleContainer);

            selectedConsoleContainer.Children.Clear();
            selectedConsoleContainer.Children.Add(selectedConsole);

            selectedConsole.IsVisible = true;
            selectedConsole.IsFocused = true;
            //selectedConsole.Position = new Point(0, 2);

            GameHost.Instance.FocusedScreenObjects.Set(selectedConsole);
            headerConsole.SetConsole(consoles[currentConsoleIndex].Title, consoles[currentConsoleIndex].Summary);

            if (currentConsoleIndex == 1)
            {
                var kaiju = KaijuGenerator.makeKaiju();
                missionKaiju = kaiju;
                battleKaiju = kaiju;
            }
            if (currentConsoleIndex == 2)
            {
                ((MissionConsole)consoles[2].Console).Kaiju = missionKaiju;
            }
            if (currentConsoleIndex == 4)
            {
                ((BattleConsole)consoles[3].Console).Kaiju = battleKaiju;
            }
        }
    }
}
