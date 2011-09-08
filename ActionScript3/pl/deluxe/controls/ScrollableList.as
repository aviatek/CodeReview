package pl.deluxe.controls
{
    import com.gskinner.motion.GTween;
    import com.gskinner.motion.easing.Exponential;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    
    import pl.deluxe.display.IItemRenderer;
    import pl.deluxe.utils.GraphicsUtil;
    
    /**
     * Component for displaying items in horizontal or vertical list.
     */
    public class ScrollableList extends List
    {
        public static const DIRECTION_HORIZONTAL : String = "horizontal";
        public static const DIRECTION_VERTICAL   : String = "vertical";
        
        private var _direction      : String = DIRECTION_HORIZONTAL;
        private var _width          : Number;
        private var _height         : Number;
        private var _contentSize    : Number;
        private var _itemsPerPage   : uint;
        private var _itemSize       : Number;
        private var _gap            : Number;
        private var _tween          : GTween;
        private var _container      : Sprite;
        private var _mask           : Sprite;
        private var _startIndex     : int = 0;
        private var _tweenDirection : int;
        private var _animated       : Boolean;
        
        /**
         * Constructor.
         * 
         * @param width Width of the component.
         * @param height Height of the component.
         * @param itemsPerPage How many items should be displayed per page.
         * @param itemSize Width or height (depending on direction) of the item in list (required for calculating positions).
         * @param gap Gap between items.
         * @param mask If <code>true</code> then list will be masked according to its width and height.
         * @param tweenDuration Duration of the tween.
         */
        public function ScrollableList(width         : Number, 
                                       height        : Number, 
                                       itemsPerPage  : uint, 
                                       itemSize      : Number, 
                                       gap           : Number, 
                                       mask          : Boolean = true, 
                                       tweenDuration : Number = 0.6, 
                                       animated      : Boolean = true)
        {
            super();
            
            _width          = width;
            _height         = height;
            _itemsPerPage   = itemsPerPage;
            _itemSize       = itemSize;
            _contentSize    = 0;
            _gap            = gap;
            _container      = new Sprite();
            _mask           = GraphicsUtil.getSpriteBox(width, height);
            
            _tween            = new GTween(_container, tweenDuration, null, {ease: Exponential.easeOut});
            _tween.onComplete = _tweenCompleteHandler;
            _tween.onChange   = _onTweenChange;
            
            _animated = animated;
            
            addChild(_container);
            
            if(mask)
            {
                _container.mask = _mask;
                addChild(_mask);
            }
        }
        
        override protected function _addedToStageHandler(event : Event) : void
        {
            super._addedToStageHandler(event);
            reset();
        }
        
        private function _tweenCompleteHandler(tween : GTween) : void
        {
            var n        : uint;
            var renderer : DisplayObject;
            
            if(_tweenDirection == 1)
            {
                n = _container.numChildren - itemsPerPage;
                
                for(var i:uint=0; i < n; i++)
                {
                    renderer = _container.getChildAt(0);
                    
                    if(renderer && _container.contains(renderer))
                    {
                        _container.removeChild(renderer);
                        _unuseRenderer(renderer as IItemRenderer);
                    }
                }
            }
            
            if(_tweenDirection == -1)
            {
                n = _container.numChildren;
                
                for(i=itemsPerPage; i < n; i++)
                {
                    renderer = _container.getChildAt(_container.numChildren-1);
                    
                    if(renderer && _container.contains(renderer))
                    {
                        _container.removeChild(renderer);
                        _unuseRenderer(renderer as IItemRenderer);
                    }
                }
            }
        }
        
        private function _onTweenChange(tween : GTween) : void
        {
            _container.x = Math.round(_container.x);
            _container.y = Math.round(_container.y);
        }
        
        /**
         * Scrolls list left (or top if direction is vertical).
         * 
         * @param numItems How many items should be scrolled.
         */
        public function scrollLeft(numItems : uint = 1) : void
        {
            var oldIndex : int = _startIndex;
            var index    : int = _startIndex - numItems;
            index = index < 0 ? 0 : index;
            
            if(oldIndex == index) return;
            
            var i : int = oldIndex - numItems;
            i = i < 0 ? 0 : i;
            var j : uint = 0;
            
            for(i; i < oldIndex; i++)
            {
                var item      : DisplayObject = _getRenderer(dataProvider[oldIndex - j - 1]) as DisplayObject;
                var firstItem : DisplayObject = _container.getChildAt(0);
                
                IItemRenderer(item).itemIndex = i;
                
                if(direction == DIRECTION_HORIZONTAL)
                {
                    item.x = firstItem.x;
                    item.x -= (_itemSize ? _itemSize : item.width) + _gap;
                }
                
                if(direction == DIRECTION_VERTICAL)
                {
                    item.y = firstItem.y;
                    item.y -= (_itemSize ? _itemSize : item.height) + _gap;
                }
                
                _container.addChildAt(item, 0);
                j++;
            }
            
            _tweenDirection = -1;
            startIndex = index;
        }
        
        /**
         * Scrolls list right (or bottom if direction is vertical).
         * 
         * @param numItems How many items should be scrolled.
         */
        public function scrollRight(numItems : uint = 1) : void
        {
            var oldIndex : int = _startIndex;
            var maxIndex : int = dataProvider.length - itemsPerPage ;
            var index    : int = _startIndex;
            
            maxIndex = maxIndex < 0 ? 0 : maxIndex;
            index    = index + numItems;
            index    = index > maxIndex ? maxIndex : index;
            
            if(oldIndex == index) return;
            
            var i : int = oldIndex + itemsPerPage;
            var n : int = i + numItems;
            
            i = i >= dataProvider.length ? dataProvider.length : i;
            n = n >= dataProvider.length ? dataProvider.length : n;
            
            for(i; i < n; i++)
            {
                var item     : DisplayObject = _getRenderer(dataProvider[i]) as DisplayObject;
                var lastItem : DisplayObject = _container.getChildAt(_container.numChildren-1);
                
                IItemRenderer(item).itemIndex = i;
                
                if(direction == DIRECTION_HORIZONTAL)
                {
                    item.y = 0;
                    item.x = lastItem.x;
                    item.x += (_itemSize ? _itemSize : lastItem.width) + _gap;
                }
                
                if(direction == DIRECTION_VERTICAL)
                {
                    item.x = 0;
                    item.y = lastItem.y;
                    item.y += (_itemSize ? _itemSize : lastItem.height) + _gap;
                }
                
                _container.addChild(item);
            }
            
            _tweenDirection = 1;
            startIndex = index;
        }
        
        /**
         * Resets list. This method should be called after some minor changes, like updating the <code>dataProvider</code>.
         */
        public function reset() : void
        {
            _tween.end();
            
            while(_container.numChildren)
            {
                var renderer : IItemRenderer = _container.removeChildAt(0) as IItemRenderer;
                _unuseRenderer(renderer);
            }
            
            _container.x = 0;
            _container.y = 0;
            _startIndex  = 0;
            
            if(dataProvider == null) return;
            
            var j : uint = 0;
            var n : uint = _startIndex + itemsPerPage;
            n = n > dataProvider.length ? dataProvider.length : n;
            
            for(var i:uint=_startIndex; i < n; i++)
            {
                var item : DisplayObject = _getRenderer(dataProvider[i]) as DisplayObject;
                
                IItemRenderer(item).itemIndex = i;
                
                if(direction == DIRECTION_HORIZONTAL)
                {
                    item.y = 0;
                    
                    if(_itemSize > 0)
                        item.x = j * (_itemSize + _gap);
                    else
                        item.x = _contentSize + item.width + _gap;
                    
                    _contentSize = item.x + (_itemSize > 0 ? _itemSize : item.width);
                }
                
                if(direction == DIRECTION_VERTICAL)
                {
                    item.x = 0;
                    
                    if(_itemSize > 0)
                        item.y = j * (_itemSize + _gap);
                    else
                        item.y = _contentSize + item.height + _gap;
                    
                    _contentSize = item.y + (_itemSize > 0 ? _itemSize : item.height);
                }
                
                _container.addChild(item);
                j++;
            }
        }
        
        /**
         * How many items are displayed per page.
         */
        public function get itemsPerPage() : uint
        {
            return _itemsPerPage;
        }
        
        override public function set width(value : Number) : void
        {
            _width = value;
        }
        
        override public function get width() : Number
        {
            return _width;
        }
        
        override public function set height(value : Number) : void
        {
            _height = value;
        }
        
        override public function get height() : Number
        {
            return _height;
        }
        
        /**
         * Index of the item currently displayed as a first item in the list.
         */
        public function get startIndex() : int
        {
            return _startIndex;
        }

        public function set startIndex(value : int) : void
        {
            _startIndex = value;
            
            if(direction == DIRECTION_HORIZONTAL)
            {
                if(_animated)
                {
                    _tween.setValues({x: -_startIndex * (_itemSize+_gap)});
                }else
                {
                    _tween.target.x = -_startIndex * (_itemSize+_gap);
                    _tweenCompleteHandler(_tween);
                }
            }
            
            if(direction == DIRECTION_VERTICAL)
            {
                if(_animated)
                {
                    _tween.setValues({y: -_startIndex * (_itemSize+_gap)});
                }else
                {
                    _tween.target.y = -_startIndex * (_itemSize+_gap);
                    _tweenCompleteHandler(_tween);
                }
            }
        }
        
        /**
         * If <code>true</code>, then we can scroll list left (or top if direction is set to vertical).
         */
        public function get canScrollLeft() : Boolean
        {
            return startIndex > 0;
        }
        
        /**
         * If <code>true</code>, then we can scroll list right (or bottom if direction is set to vertical).
         */
        public function get canScrollRight() : Boolean
        {
            return startIndex + itemsPerPage < dataProvider.length;
        }
        
        /**
         * Direction of the list. Possible values are <code>ScrollableList.DIRECTION_HORIZONTAL</code> and <code>ScrollableList.DIRECTION_VERTICAL</code>.
         * 
         * @default horizontal
         */
        public function get direction() : String
        {
            return _direction;
        }

        public function set direction(value : String) : void
        {
            _direction = value;
        }
        
        public function get contentWidth() : Number
        {
            return _container.width;
        }
        
        public function get contentHeight() : Number
        {
            return _container.height;
        }
        
        /**
         * Size (width or height, deppending on direction) of one item in the list.
         */
        public function get itemSize() : Number
        {
            return _itemSize;
        }
        
        /**
         * Gap (distance) between items in the list.
         */
        public function get gap() : Number
        {
            return _gap;
        }
    }
}