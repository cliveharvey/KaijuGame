using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Console = SadConsole.Console;
using System.Threading.Tasks;

namespace KaijuGame.Consoles.Screens
{
    internal class BaseConsole : Console
    {
        public BaseConsole() : base(80, 25)
        {

        }
    }
}
