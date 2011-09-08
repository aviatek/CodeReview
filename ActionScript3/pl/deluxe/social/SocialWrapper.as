package pl.deluxe.social
{
    import flash.events.EventDispatcher;
    
    import pl.deluxe.events.SocialWrapperEvent;
    import pl.deluxe.model.UserModel;
    
    [Event(type="pl.deluxe.events.SocialWrapperEvent", name="ready")]
    [Event(type="pl.deluxe.events.SocialWrapperEvent", name="loadFriendsComplete")]
    [Event(type="pl.deluxe.events.SocialWrapperEvent", name="loadUserInfoComplete")]
    [Event(type="pl.deluxe.events.SocialWrapperEvent", name="postToWallSuccess")]
    [Event(type="pl.deluxe.events.SocialWrapperEvent", name="postToWallFailed")]
    [Event(type="pl.deluxe.events.SocialWrapperEvent", name="inviteFriendsFailed")]
    [Event(type="pl.deluxe.events.SocialWrapperEvent", name="inviteFriendsSuccess")]
    [Event(type="pl.deluxe.events.SocialWrapperEvent", name="askForLivesSuccess")]
    [Event(type="pl.deluxe.events.SocialWrapperEvent", name="askForLivesFailed")]
    [Event(type="pl.deluxe.events.SocialWrapperEvent", name="sendLifeToFriendSuccess")]
    [Event(type="pl.deluxe.events.SocialWrapperEvent", name="sendLifeToFriendFailed")]
    
    /**
     * Abstract class for implementing social functionalities of social platforms like Facebook or Hi5.
     */
    public class SocialWrapper extends EventDispatcher
    {
        public static var APP_ID     : String;
        public static var CANVAS_URL : String; 
        
        protected var _userID      : String;
        protected var _initialized : Boolean;
        protected var _userData    : Object;
        protected var _friendsData : Object;
        
        public function SocialWrapper()
        {
            super();
        }
        
        /**
         * Initilizes wrapper.
         * 
         * @param userID Platfrom user id (if needed).
         */
        public function init(userID : String = "") : void
        {
            _userID = userID;
            dispatchEvent(new SocialWrapperEvent(SocialWrapperEvent.READY));
        }
        
        /**
         * Updates provided model with data provided in data. 
         * This methods must be overriden to provide network specific mapping.
         */ 
        public function updateUserModel(model : UserModel, data : Object) : void
        {
            throw new Error("Method must be overriden");
        }
        
        /**
         * Loads user info.
         */
        public function loadUserInfo() : void
        {
            throw new Error("Method must be overriden");
        }
        
        /**
         * Loads user friends info.
         */
        public function loadFriends() : void
        {
            throw new Error("Method must be overriden");
        }
        
        /**
         * Posts message to wall (or similar platfrom specific channels).
         * 
         * @param message Message to post.
         */
        public function postToWall(message : ViralMessage) : void
        {
            throw new Error("Method must be overriden");
        }
        
        /**
         * Displays "invite friends" dialog specific for the platform.
         */
        public function inviteFriends(message : ViralMessage = null) : void
        {
            throw new Error("Method must be overriden");
        }
        
        /**
         * Displays "requests" dialog for asking friends for lives.
         */
        public function askForLives(filterUsers : Array = null) : void
        {
            throw new Error("Method must be overriden");
        }
        
        /**
         * Displays "requests" dialog for sending lives to friends.
         */
        public function sendLifeToFriend(friendExternalId : String) : void
        {
            throw new Error("Method must be overriden");
        }
        
        /**
         * @return List of all user firends ids.
         */
        public function getListOfAllFriendsIds() : Array
        {
            throw new Error("Method must be overriden");
        }

        public function get initialized() : Boolean
        {
            return _initialized;
        }
        
        public function get networkId() : uint
        {
            throw new Error("Method must be overriden");
            return "";
        }

        public function get userData() : Object
        {
            return _userData;
        }

        public function get friendsData() : Object
        {
            return _friendsData;
        }
        
        /**
         * Locale of the app viewer. For example: <code>en_US</code> or <code>pl_PL</code>.
         */
        public function get locale() : String
        {
            return "en_All";
        }
        
        /**
         * Url to directory with wall post images.
         */
        public function get wallPostImagesUrl() : String
        {
            return "";
        }

    }
}