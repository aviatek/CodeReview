package pl.deluxe.controls
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    
    import pl.deluxe.display.UIComponent;
    import pl.deluxe.log.Log;
    
    /**
     * Dispatched when loading photo completes.
     */
    [Event(type="flash.events.Event", name="complete")]
    
    /**
     * Class for loading and displaying "smoothed" user image.
     * It uses BitmapData smoothing and it is able to ommit flash player sandbox restrictions and 
     * smooth images out of application sandbox properly.
     */
    public class UserPhoto extends UIComponent
    {
        private var _container      : Sprite;
        private var _loader         : Loader;
        private var _imageContainer : Sprite;
        private var _fitToSize      : Boolean;
        private var _photoUrl       : String;
        private var _loaded         : Boolean;
        
        public function UserPhoto(url : String = null)
        {
            super();
            
            _imageContainer = new Sprite();
            _container = new Sprite();
            addChild(_container);
            
            fitToSize = true;
            
            if(url)
                loadPhoto(url);
        }
        
        private function _ioErrorHandler(event : IOErrorEvent) : void
        {
            Log.info("UserPhoto._ioErrorHandler: " + event.text);
        }
        
        private function _loadBytesCompleteHandler(event : Event) : void
        {
            var loader : Loader = LoaderInfo(event.currentTarget).loader;
            
            try
            {
                var bd : BitmapData = new BitmapData(loader.width, loader.height, false);
                bd.draw(loader.content);
                var bmp : Bitmap = new Bitmap(bd, PixelSnapping.AUTO, true);
                
                _loaded = true;
                _imageContainer.addChild(bmp);
                _container.addChild(_imageContainer);
                validateDisplayList();
                dispatchEvent(new Event(Event.COMPLETE));
            }
            catch(e:Error)
            {
                _showImageOutOfSandbox();
            }
        }
        
        private function _loaderCompleteHandler(event : Event) : void
        {
            try
            {
                var data   : ByteArray = _loader.contentLoaderInfo.bytes;
                var loader : Loader = new Loader();
                
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _loadBytesCompleteHandler);
                loader.loadBytes(data);
            }
            catch(e : Error)
            {
                _showImageOutOfSandbox();
            }
        }
        
        private function _showImageOutOfSandbox() : void
        {
            _loaded = true;
            _imageContainer.addChild(_loader);
            
            _container.addChild(_imageContainer);
            validateDisplayList();
            dispatchEvent(new Event(Event.COMPLETE));
        }
        
        override protected function updateDisplayList() : void
        {
            if(fitToSize && _loaded)
            {
                _imageContainer.width = width;
                _imageContainer.height = height;
            }
            
            super.updateDisplayList();
        }
        
        /**
         * Loads user photo (or any other image).
         * 
         * @param url Url to the image.
         */
        public function loadPhoto(url : String) : void
        {
            if(!_loader)
            {
                _loader = new Loader();
                _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
                _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _loaderCompleteHandler);
            }
            
            if(_photoUrl != url)
            {
                while(_container.numChildren)
                    _container.removeChildAt(0);
                
                _loaded   = false;
                _photoUrl = url;
                _loader.load(new URLRequest(url));
            }
        }
        
        /**
         * If <code>true</code> image will be resized to fit component dimensions.
         * @default <code>true</code>
         */
        public function get fitToSize() : Boolean
        {
            return _fitToSize;
        }

        public function set fitToSize(value : Boolean) : void
        {
            _fitToSize = value;
        }

        public function get photoUrl() : String
        {
            return _photoUrl;
        }
    }
}