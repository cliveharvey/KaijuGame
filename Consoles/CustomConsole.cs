using SadConsole;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KaijuGame.Consoles
{
    internal class CustomConsole
    {
        public string Title;
        public string Summary;

        public IScreenObject Console
        {
            get;
            set;
        }

        public CustomConsole(IScreenObject console, string title, string summary)
        {
            Console = console;
            Title = title;
            Summary = summary;
        }
    }
}
