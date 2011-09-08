<?php
/**
 * @category       Application
 * @package        Application_Model_Mappers
 * @author         Bartosz Szymanski
 */

class Application_Models_Mappers_Users extends Shard_Models_Mappers_Shard_Abstract
{
    protected $_dbTableName = "Application_Models_DbTable_Users";
    protected $_rowClass    = "Application_Models_User";

    /**
     * Get user model - load existing account or create new one
     * 
     * @param string $userId
     * @return Application_Models_User
     */
    public function getUser($userId)
    {
        $user = $this->find($userId);

        if($user)
            return $user;
        else
            return $this->createNewUser($userId);
    }
    
    /**
     * Add new user to database with default values
     * 
     * @see Application_Configs_Constants
     * @param string $userId
     * @return Application_Models_User
     */
    private function createNewUser($userId)
    {
        $user                     = new Application_Models_User();
        $user->userId             = $userId;
        $user->coins              = Application_Configs_Constants::INITIAL_PREMIUM_COINS;
        $user->lives              = Application_Configs_Constants::INITIAL_LIVES;
        $user->lastLivesTime      = time();
        $user->lastDailyBonusTime = 0;
        $user->dailyBonusLevel    = 0;
        $user->livesFromFriends   = 0;
        $user->livesBought        = 0;
        $user->spinsLeft          = 1;
        $user->flags              = 0;
        $user->lastTournamentSeen = 0;
        $user->removalTime        = 0;
        $user->registerTime       = time();

        $usersMapper = new Application_Models_Mappers_Users();
        return $usersMapper->save($user);
    }

    /** 
     * Find user based on userId
     * 
     * @param string $userId
     * @return Application_Models_User | null if user not exists
     */
    public function find($userId)
    {
        $query = $this->getDbTable()->select()->where("userId=?" , $userId);
        $res   = $this->fetchAll($query);
        
        if(isSet($res[0]))
            return $res[0];
        else
            return null;
    }
    
    public function countUsersRegisteredBetween($registeredFrom, $registeredTo, $includeInactive = true)
    {
        $query = $this->getDbTable()->select()
                      ->from($this->getDbTable()->_name, array('count(*) as count'))
                      ->where("registerTime > ?" , $registeredFrom)
                      ->where("registerTime < ?" , $registeredTo);
        
        if($includeInactive == false)
            $query = $query->where("removalTime = 0");
            
        $res = $this->fetchAll($query);
        
        if(isSet($res[0]))
            return $res[0]->count;
        else
            return null;
    }
    
    public function getNewInstallsReport($from_timestamp, $to_timestamp)
    {
        $select = "COUNT(DISTINCT userId) as count, day(FROM_UNIXTIME(`registerTime`)) as day, month(FROM_UNIXTIME(`registerTime`)) as month, year(FROM_UNIXTIME(`registerTime`)) as year";
        $query  = $this->getDbTable()->select()->from($this->getDbTable()->_name, $select);

        $query->group(array("day","month","year"));
        
        $day   = date("d", $from_timestamp);
        $month = date("m", $from_timestamp);
        $year  = date("Y", $from_timestamp);
        
        $fromTimestamp = mktime(0,0,0,$month, $day, $year);
        
        $timestamp = time();
        $day       = date("d", $to_timestamp);
        $month     = date("m", $to_timestamp);
        $year      = date("Y", $to_timestamp);
        
        $toTimestamp = mktime(0,0,0,$month, $day, $year);

        $query->where('registerTime > ?', $fromTimestamp);
        $query->where('registerTime < ?', $toTimestamp);

        $query->order(array('month ASC', 'day ASC', 'year ASC'));
        
        $out = $this->getDbTable()->fetchAll($query)->toArray();
        
        return $out;
    }
    
    public function getUninstallsReport($from_timestamp, $to_timestamp)
    {
        $select = "COUNT(DISTINCT userId) as count, day(FROM_UNIXTIME(`removalTime`)) as day, month(FROM_UNIXTIME(`removalTime`)) as month, year(FROM_UNIXTIME(`removalTime`)) as year";
        $query  = $this->getDbTable()->select()->from($this->getDbTable()->_name,$select);

        $query->group(array("day","month","year"));
        
        $day   = date("d", $from_timestamp);
        $month = date("m", $from_timestamp);
        $year  = date("Y", $from_timestamp);

        $fromTimestamp = mktime(0,0,0,$month, $day, $year);
        
        $timestamp = time();
        $day       = date("d", $to_timestamp);
        $month     = date("m", $to_timestamp);
        $year      = date("Y", $to_timestamp);
        
        $toTimestamp = mktime(0,0,0,$month, $day, $year);

        $query->where('removalTime > ?', $fromTimestamp);
        $query->where('removalTime < ?', $toTimestamp);

        $query->order(array('month ASC', 'day ASC', 'year ASC'));
        
        return $this->getDbTable()->fetchAll($query)->toArray();
    }
    
    public function getTotalUsersReport($from_timestamp, $to_timestamp, $includeNotActive = true)
    {
        $days   = ($to_timestamp - $from_timestamp) / (60*60*24);
        $result = array();
        
        for($i=0; $i < $days; $i++)
        {
            $ts    = $from_timestamp + ($i * (60*60*24));
            $day   = date("d", $ts);
            $month = date("m", $ts);
            $year  = date("Y", $ts);
            
            $query = $this->getDbTable()->select()->from($this->getDbTable()->_name, 'COUNT(DISTINCT userId) as count')
                          ->where('registerTime < ?', $ts);
            
            if($includeNotActive == false)
                $query = $query->where('removalTime = 0');
                
            $queryResult = $this->getDbTable()->fetchAll($query)->toArray();
            
            $stat          = array();
            $stat['day']   = $day;
            $stat['month'] = $month;
            $stat['year']  = $year;
            $stat['count'] = $queryResult[0]['count'];
            $result[]      = $stat;
        }
        
        return $result;
    }
    
    public function getNumberOfActiveUsers($delay)
    {
        // --- Getting active users in last 10 minutes --- //
        $queryRecentlyActive = $this->getDbTable()->select()->from("Users", "COUNT(*) as count");

        $queryRecentlyActive->where('lastLoginTime>=? ', time() - $delay);
        $queryRecentlyActiveUsers = $this->getDbTable()->fetchAllFromAllShards($queryRecentlyActive);

        $recentlyActiveUsersCount = 0;
        foreach($queryRecentlyActiveUsers as $recentlyActiveUsersOnShard)
        {
            $recentlyActiveUsersCount += $recentlyActiveUsersOnShard->count;
        }
        // --- Getting active users in last 10 minutes END --- //
        
        return $recentlyActiveUsersCount;
    }
}