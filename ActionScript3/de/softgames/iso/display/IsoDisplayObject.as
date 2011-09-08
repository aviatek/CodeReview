package de.softgames.iso.display
{
    import de.softgames.display.BitmapMovieClip;
    import de.softgames.iso.IsoScene;
    import de.softgames.iso.geom.IsoPoint;
    import de.softgames.model.iso.IsoItemModel;
    
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    public class IsoDisplayObject extends Sprite
    {
        protected var _asset          : DisplayObject;
        private var _bitmapAsset      : BitmapMovieClip;
        private var _cacheAsBitmap    : Boolean;
        private var _positionPoint    : IsoPoint;
        private var _width            : Number;
        private var _length           : Number;
        private var _height           : Number;
        private var _scene            : IsoScene;
        private var _debugSprite      : Sprite;
        private var _drawDebugBounds  : Boolean;
        private var _rotation         : uint = 1;
        private var _model            : IsoItemModel;
        private var _depth            : uint = 0;
        private var _isDynamic        : Boolean;
        private var _renderBounds     : Rectangle;
        private var _animated         : Boolean;
        private var _zoom             : Number = 1;
        
        public function IsoDisplayObject()
        {
            super();
            
            _renderBounds  = new Rectangle();
            _positionPoint = new IsoPoint();
            addEventListener(MouseEvent.CLICK, _clickHandler);
            addEventListener(Event.ADDED_TO_STAGE, _addedToStageHandler);
            addEventListener(Event.REMOVED_FROM_STAGE, _removedFromStageHandler);
        }
        
        private function _clickHandler(event : MouseEvent) : void
        {
            dispatchEvent(new Event(Event.SELECT, true));
        }
        
        private function _stopMC(mc : MovieClip) : void
        {
            for each(var child : MovieClip in mc)
            if(child) _stopMC(mc);
            
            if(mc) mc.gotoAndStop(1);
        }
        
        protected function _addedToStageHandler(event : Event) : void
        {
            
        }
        
        protected function _removedFromStageHandler(event : Event) : void
        {
            
        }
        
        protected function _updateSorter() : void
        {
            
        }
        
        protected function _drawBounds() : void
        {
            var p : IsoPoint = new IsoPoint();
            var g : Graphics = debugSprite.graphics;
            
            p.x = 0;
            p.y = 0;
            g.moveTo(p.cartesianX, p.cartesianY);
            
            g.lineStyle(1, 0xff0000, 1);
            
            p.x = 0;
            p.y = 0;
            p.z = height;
            g.moveTo(p.cartesianX, p.cartesianY);
            
            p.x = 0 + width;
            p.y = 0;
            p.z = height;
            g.lineTo(p.cartesianX, p.cartesianY);
            
            p.x = 0 + width;
            p.y = 0;
            p.z = 0;
            g.lineTo(p.cartesianX, p.cartesianY);
            
            p.x = 0 + width;
            p.y = 0 + length;
            p.z = 0;
            g.lineTo(p.cartesianX, p.cartesianY);
            
            p.x = 0;
            p.y = 0 + length;
            p.z = 0;
            g.lineTo(p.cartesianX, p.cartesianY);
            
            p.x = 0;
            p.y = 0 + length;
            p.z = height;
            g.lineTo(p.cartesianX, p.cartesianY);
            
            p.x = 0;
            p.y = 0;
            p.z = height;
            g.lineTo(p.cartesianX, p.cartesianY);
            g.endFill();
            
            p.x = width;
            p.y = 0;
            p.z = height;
            g.moveTo(p.cartesianX, p.cartesianY);
            
            p.x = width;
            p.y = length;
            p.z = height;
            g.lineTo(p.cartesianX, p.cartesianY);
            
            p.x = 0;
            p.y = length;
            p.z = height;
            g.lineTo(p.cartesianX, p.cartesianY);
            
            p.x = width;
            p.y = length;
            p.z = height;
            g.moveTo(p.cartesianX, p.cartesianY);
            
            p.x = width;
            p.y = length;
            p.z = 0;
            g.lineTo(p.cartesianX, p.cartesianY);
        }
        
        /**
         * Updates on screen (2d) position according to isometric position.
         */
        public function updatePosition() : void
        {
            screenX = _positionPoint.cartesianX;
            screenY = _positionPoint.cartesianY;
            _updateSorter();
        }
        
        /**
         * Moves object to cordinates in isometric perspective.
         */
        public function moveTo(x : Number, y : Number, z : Number) : void
        {
            positionPoint.x = x;
            positionPoint.y = y;
            positionPoint.z = z;
            updatePosition();
        }
        
        public function setSize(width : Number, length : Number, height : Number) : void
        {
            _width = width;
            _length = length;
            _height = height;
            if(drawDebugBounds) _drawBounds();
        }
        
        public function getRenderBounds() : Rectangle
        {
            _renderBounds.x       = viewportTopLeftX;
            _renderBounds.y       = viewportTopY;
            _renderBounds.width   = Math.abs(_renderBounds.x - viewportTopRightX);
            _renderBounds.height  = Math.abs(_renderBounds.y - viewportBottomY);
            
            return _renderBounds;
        }
        
        /**
         * Checks if object is in viewport bounds and therefore should be displayed. 
         * If object is outside bounds than it is removed from display list.
         */
        public function checkIfItemIsInViewportBounds() : void
        {
            var viewportBounds : Rectangle = scene.viewport.renderBounds.clone();
            var itemBounds     : Rectangle = getRenderBounds().clone();
            
            viewportBounds.x = viewportBounds.x - (viewportBounds.width * (1 / scene.zoom) - viewportBounds.width) / 2;
            viewportBounds.y = viewportBounds.y - (viewportBounds.height * (1 / scene.zoom) - viewportBounds.height) / 2;
            viewportBounds.width *= 1 / scene.zoom;
            viewportBounds.height *= 1 / scene.zoom;
            
            viewportBounds.offset(scene.viewport.itemsContainerOffset.x, scene.viewport.itemsContainerOffset.y);
            viewportBounds.offset(-scene.viewport.width / 2, -scene.viewport.height / 2);
            
            if(itemBounds.intersects(viewportBounds))
            {
                if(stage == null) scene.viewport.addIsoItem(this);
            }
            else
            {
                if(stage) scene.viewport.removeIsoItem(this);
            }
        }
        
        /**
         * Disposes object.
         */
        public function dispose() : void
        {
            disposeAsset();
        }
        
        /**
         * Disposes object asset.
         */
        public function disposeAsset() : void
        {
            if(asset is MovieClip)
                _stopMC(asset as MovieClip);
        }
        
        /**
         * Calculates object depth for depth sorting algorithm.
         */
        public static function getDepth(x : Number, y : Number, z : Number) : Number
        {
            return Math.round(x + y) * 0.866 + Math.round(z) * 0.707 + Math.round(x) * 0.707;
        }
        
        override public function get x() : Number
        {
            return _positionPoint.x;
        }
        
        override public function set x(value : Number) : void
        {
            _positionPoint.x = value;
            updatePosition();
        }
        
        override public function get y() : Number
        {
            return _positionPoint.y;
        }
        
        override public function set y(value : Number) : void
        {
            _positionPoint.y = value;
            updatePosition();
        }
        
        override public function get z() : Number
        {
            return _positionPoint.z;
        }
        
        override public function set z(value : Number) : void
        {
            _positionPoint.z = value;
            updatePosition();
        }
        
        public function get positionPoint() : IsoPoint
        {
            return _positionPoint;
        }
        
        public function set positionPoint(value : IsoPoint) : void
        {
            _positionPoint = value;
            updatePosition();
        }
        
        /**
         * Onscreen x position (in local cordinates system).
         */
        public function get screenX() : Number
        {
            return super.x;
        }
        
        public function set screenX(value : Number) : void
        {
            super.x = value;
        }
        
        /**
         * Onscreen y position (in local cordinates system).
         */
        public function get screenY() : Number
        {
            return super.y;
        }
        
        public function set screenY(value : Number) : void
        {
            super.y = value;
        }
        
        override public function get width() : Number
        {
            return _width;
        }
        
        override public function set width(value : Number) : void
        {
            _width = value;
            if(drawDebugBounds) _drawBounds();
        }
        
        public function get length() : Number
        {
            return _length;
        }
        
        public function set length(value : Number) : void
        {
            _length = value;
            if(drawDebugBounds) _drawBounds();
        }
        
        override public function get height() : Number
        {
            return _height;
        }
        
        override public function set height(value : Number) : void
        {
            _height = value;
            if(drawDebugBounds) _drawBounds();
        }
        
        public function get scene() : IsoScene
        {
            return _scene;
        }
        
        public function set scene(value : IsoScene) : void
        {
            _scene = value;
        }
        
        /**
         * Asset applied to this object.
         */
        public function get asset() : DisplayObject
        {
            return _asset;
        }

        public function set asset(value : DisplayObject) : void
        {
            _asset = value;
            while(numChildren)
                removeChildAt(0);
            
            if(cacheAsBitmap)
            {
                _bitmapAsset = new BitmapMovieClip(asset, animated);
                _bitmapAsset.smoothing = false;
                addChild(_bitmapAsset);
            }else
            {
                addChild(asset);
            }
            
            rotation = this.rotation;
        }        

        public function get debugSprite() : Sprite
        {
            if(!_debugSprite)
            {
                _debugSprite = new Sprite();
                addChild(_debugSprite);
            }
            
            return _debugSprite;
        }
        
        /**
         * If <code>true</code> than debugger will draw object isometric bounds.
         */
        public function get drawDebugBounds() : Boolean
        {
            return _drawDebugBounds;
        }

        public function set drawDebugBounds(value : Boolean) : void
        {
            _drawDebugBounds = value;
            if(drawDebugBounds) _drawBounds();
        }

        override public function get rotation() : Number
        {
            return _rotation;
        }

        override public function set rotation(value : Number) : void
        {
            _rotation = value;
            if(asset)
            {
                if(cacheAsBitmap)
                    MovieClip(_bitmapAsset.asset).gotoAndStop(rotation);
                else
                    MovieClip(asset).gotoAndStop(rotation);
            }
        }
        
        override public function set cacheAsBitmap(value : Boolean) : void
        {
            _cacheAsBitmap = value;
        }
        
        override public function get cacheAsBitmap() : Boolean
        {
            return _cacheAsBitmap;
        }

        public function get model() : IsoItemModel
        {
            return _model;
        }

        public function set model(value : IsoItemModel) : void
        {
            _model = value;
        }
        
        public function set depth(value : uint) : void
        {
            _depth = value;
        }
        
        public function get depth() : uint
        {
            return _depth;
        }
        
        public function get viewportTopLeftX() : Number
        {
            return IsoPoint.calculateCartesianX(x, y + length, z + height);
        }
        
        public function get viewportTopLeftY() : Number
        {
            return IsoPoint.calculateCartesianY(x, y + length, z + height);
        }
        
        public function get viewportTopX() : Number
        {
            return IsoPoint.calculateCartesianX(x, y, z + height);
        }
        
        public function get viewportTopY() : Number
        {
            return IsoPoint.calculateCartesianY(x, y, z + height);
        }
        
        public function get viewportTopRightX() : Number
        {
            return IsoPoint.calculateCartesianX(x + width, y, z + height);
        }
        
        public function get viewportTopRightY() : Number
        {
            return IsoPoint.calculateCartesianY(x + width, y, z + height);
        }
        
        public function get viewportBottomLeftX() : Number
        {
            return IsoPoint.calculateCartesianX(x, y + length, z);
        }
        
        public function get viewportBottomLeftY() : Number
        {
            return IsoPoint.calculateCartesianY(x, y + length, z);
        }
        
        public function get viewportBottomX() : Number
        {
            return IsoPoint.calculateCartesianX(x + width, y + length, z);
        }
        
        public function get viewportBottomY() : Number
        {
            return IsoPoint.calculateCartesianY(x + width, y + length, z);
        }
        
        public function get viewportBottomRightX() : Number
        {
            return IsoPoint.calculateCartesianX(x + width, y, z);
        }
        
        public function get viewportBottomRightY() : Number
        {
            return IsoPoint.calculateCartesianY(x + width, y, z);
        }
        
        public function get tileX() : uint
        {
            return Math.round(x / scene.tileSize);
        }
        
        public function get tileY() : uint
        {
            return Math.round(x / scene.tileSize);
        }
        
        /**
         * Determines if item is dynamic (need to be resorted every frame or sort cycle).
         */ 
        public function get isDynamic() : Boolean
        {
            return _isDynamic;
        }

        public function set isDynamic(value : Boolean) : void
        {
            _isDynamic = value;
        }

        public function get animated() : Boolean
        {
            return _animated;
        }

        public function set animated(value : Boolean) : void
        {
            _animated = value;
        }

        public function get zoom() : Number
        {
            return _zoom;
        }

        public function set zoom(value : Number) : void
        {
            if(zoom != value)
            {
                _zoom = value;
                
                if(_bitmapAsset)
                {
                    _bitmapAsset.asset.scaleX = zoom;
                    _bitmapAsset.asset.scaleY = zoom;
                    _bitmapAsset.render();
                    _bitmapAsset.width = asset.width / zoom;
                    _bitmapAsset.height = asset.height / zoom;
                }
            }
        }
    }
}