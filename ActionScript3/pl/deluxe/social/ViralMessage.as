package pl.deluxe.social
{
    public class ViralMessage
    {
        public var title   : String = "";
        public var message : String = "";
        public var picture : String = "";
        public var type    : uint;
        public var to      : String = "";
        
        public function toString() : String
        {
            var out : String = "[ViralMessage \n";
            out += "   title: " + title + "\n";
            out += "   message: " + message + "\n";
            out += "   type: " + type + "\n";
            out += "   picture: " + picture + "\n";
            out += "]";
            
            return out;
        }
    }
}