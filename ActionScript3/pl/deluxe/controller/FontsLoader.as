package pl.deluxe.controller
{
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;
    import flash.text.Font;
    
    import pl.deluxe.log.Log;
    
    [Event(type="flash.events.Event", name="complete")]
    
    /**
     * Class for bulk preloading all fonts needed by the application.
     */
    public class FontsLoader extends EventDispatcher
    {
        private var _fontNames  : Array  = [];
        private var _fontsDir   : String = "";
        private var _lang       : String = "";
        private var _loadIndex  : int    = -1;
        
        public function FontsLoader()
        {
            super();
        }
        
        private function _loadNextFont() : void
        {
            var fontName : String = _fontNames[++_loadIndex];
            var url      : String = fontsDir + (lang.length ? lang+"_":"") + fontName + ".swf";
            var loader   : Loader = new Loader();
            
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _fontLoaderCompleteHandler);
            loader.load(new URLRequest(url));
        }
        
        private function _ioErrorHandler(event : IOErrorEvent) : void
        {
            throw new Error("Error loading font");
        }
        
        private function _fontLoaderCompleteHandler(event : Event) : void
        {
            if(_loadIndex < _fontNames.length-1)
                _loadNextFont();
            else
            {
                dispatchEvent(new Event(Event.COMPLETE));
                Log.info(" ");
                Log.info("Fonts Loader available fonts:");
                
                var fonts : Array = Font.enumerateFonts();
                for(var p:String in fonts)
                    Log.info(fonts[p].fontName);
                
                Log.info(" ---------- ");
                Log.info(" ");
            }
        }
        
        /**
         * Adds font to loader.
         * 
         * @param fontName Name of the font. For example <code>Arial</code>.
         */
        public function addFont(fontName : String) : void
        {
            if(_fontNames.indexOf(fontName) == -1)
                _fontNames.push(fontName);
        }
        
        /**
         * Starts loading all fonts.
         */
        public function loadAllFonts() : void
        {
            _loadNextFont();
        }
        
        /**
         * Url to the directory with all fonts (compiled into swf's).
         */
        public function get fontsDir() : String
        {
            return _fontsDir;
        }

        public function set fontsDir(value : String) : void
        {
            _fontsDir = value;
        }

        public function get lang() : String
        {
            return _lang;
        }

        public function set lang(value : String) : void
        {
            _lang = value;
        }
    }
}