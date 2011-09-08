package pl.deluxe.model
{
    import pl.deluxe.view.gameboard.NodeView;

    public class Node
    {
        private var _x         : uint;
        private var _y         : uint;
        private var _type      : String;
        private var _newType   : String;
        private var _newColor  : String;
        private var _color     : String;
        private var _blobDelay : Number;
        
        public var powerupUsed     : Boolean;
        public var powerupUsedType : String;
        public var view            : NodeView;
        public var locked          : Boolean;
        public var visited         : Boolean;
        public var isHint          : Boolean;
        
        public function Node(x : uint = 0, y : uint = 0, blobDelay : Number = -1)
        {
            this.x = x;
            this.y = y;
            _blobDelay = blobDelay;
        }
        
        public function clone() : Node
        {
            var node : Node  = new Node(x, y, _blobDelay);
            node.type        = type;
            node.newType     = type;
            node.view        = view;
            node.color       = color;
            node.powerupUsed = powerupUsed;
            return node;
        }
        
        public function setBlobDelay(delay : Number = -1) : void
        {
            _blobDelay = delay;
        }
        
        public function getBlobDelay(index : int = -1) : Number
        {
            if(index == -1 && _blobDelay == -1)
                return 0;
            
            if(index >= 0 && _blobDelay == -1)
                return GameBoardConstans.DEFAULT_BLOB_DELAY * index;
            
            return _blobDelay;
        }
        
        public function dispose() : void
        {
            if(view)
                view.dispose();
            view = null;
        }
        
        public function toString() : String
        {
            return "[Node x: " + x + ", y: " + y + ", type: " + type + ", color: " + color + "]";
        }
        
        public function get canBeBlobbed() : Boolean
        {
            return type != NodeType.BLANK && type != NodeType.BLOCKER;
        }
        
        public function get isPowerup() : Boolean
        {
            return type == NodeType.POWERUP_STAR || 
                   type == NodeType.POWERUP_AUREOLE ||
                   type == NodeType.POWERUP_BOMB;
        }
        
        public function get isBooster() : Boolean
        {
            return type == NodeType.BOOSTER_RAINBOW;
        }
        
        public function get isChain() : Boolean
        {
            return type == NodeType.CHAIN_ONE || type == NodeType.CHAIN_TWO || type == NodeType.CHAIN_THREE;
        }
        
        public function get isUmbrella() : Boolean
        {
            return type == NodeType.UMBRELLA;
        }

        public function get x() : uint
        {
            return _x;
        }

        public function set x(value : uint) : void
        {
            _x = value;
        }

        public function get y() : uint
        {
            return _y;
        }

        public function set y(value : uint) : void
        {
            _y = value;
        }

        public function get type() : String
        {
            return _type;
        }

        public function set type(value : String) : void
        {
            _type = value;
        }

        public function get color() : String
        {
            return _color;
        }

        public function set color(value : String) : void
        {
            _color = value;
        }

        public function get newType() : String
        {
            return _newType;
        }

        public function set newType(value : String) : void
        {
            _newType = value;
        }

        public function get newColor() : String
        {
            return _newColor;
        }

        public function set newColor(value : String) : void
        {
            _newColor = value;
        }

    }
}