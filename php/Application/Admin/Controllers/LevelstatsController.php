<?php
/**
 * @category       Application
 * @package        Application_Controllers
 * @author         Bartosz Szymanski
 */

class Admin_LevelstatsController extends Application_Admin_Controllers_AuthController
{
    protected $registered_from;
    protected $registered_from_ts;
    protected $registered_to;
    protected $registered_to_ts;
    protected $type;
    protected $usersCount;
    protected $parsedFunnel;
    protected $funnel;
    
    public function preDispatch()
    {
        parent::preDispatch();
        $this->_redirector = $this->_helper->getHelper('Redirector');
    }

    public function init()
    {
        
    }
    
    public function generateFunnel()
    {
        if(!$this->getRequest()->getParam("registered_from"))
            $this->getRequest()->setParam("registered_from", date("d-m-Y", time() - (7 * 24 * 60 * 60)));
            
		if(!$this->getRequest()->getParam("registered_to"))
            $this->getRequest()->setParam("registered_to", date("d-m-Y", time()));
            
        if(!$this->getRequest()->getParam("type"))
            $this->getRequest()->setParam("type", 1);
            
        $this->registered_from    = $this->getRequest()->getParam("registered_from");
        $this->registered_from_ts = strtotime($this->registered_from);
        $this->registered_to      = $this->getRequest()->getParam("registered_to");
        $this->registered_to_ts   = strtotime($this->registered_to);
        $this->type               = $this->getRequest()->getParam("type");
        
        $scoresMapper = new Application_Models_Mappers_ScoresExplorer();
        $usersMapper  = new Application_Models_Mappers_Users();
        
        $this->funnel       = $scoresMapper->levelsFunnel($this->registered_from_ts, $this->registered_to_ts);
        $this->usersCount   = $usersMapper->countUsersRegisteredBetween($this->registered_from_ts, $this->registered_to_ts);
        $this->parsedFunnel = $this->parseFunnel($this->funnel, $this->usersCount, $this->type);
    }

    public function indexAction()
    {
        $this->generateFunnel();
        
        $filters = array
        (
            array(
                'name' => 'registered_from',
                'label' => 'From: ',
                'class' => 'datepicker_from'
            ),
            array(
                'name' => 'registered_to',
                'label' => 'To: ',
                'class' => 'datepicker_to'
            )
        );
        
        $filtersForm = new Application_Admin_Form_LevelstatsFilters($filters);
        $filtersForm->populate($this->getRequest()->getParams());
        
        $this->view->registeredFilters  = $filtersForm;
        $this->view->sidebar            = $this->view->render("levelstats/sidebar.phtml");
        $this->view->registered_from    = $this->registered_from;
        $this->view->registered_to      = $this->registered_to;
        $this->view->registered_from_ts = $this->registered_from_ts;
        $this->view->registered_to_ts   = $this->registered_to_ts;
        $this->view->funnel             = $this->parsedFunnel;
        $this->view->totalUsers         = $this->usersCount;
        $this->view->type               = $this->type;
    }
    
    public function exportAction()
    {
        $this->generateFunnel();
        $this->_helper->layout->disableLayout();
        $this->_helper->viewRenderer->setNoRender();
        
        $fileName = "Levels Stats for ".$this->registered_from." to ".$this->registered_to.".csv";

        header('Content-type: text/csv');
        header('Content-Disposition: attachment; filename="'.$fileName.'"');
        
        echo $this->getCsv($fileName);
    }
    
    public function getCsv($fileName)
    {
        $fp = fopen('php://temp', 'w');
        
        foreach($this->parsedFunnel as $island)
        {
            foreach($island['levels'] as $level)
            {
                $row = array($island['islandId'], $level['levelId'], $level['count']);
                fputcsv($fp, $row);
            }
        }
        
        rewind($fp);
        $output = stream_get_contents($fp);
        fclose($fp);
        return $output;
    }
    
    public function parseFunnel($funnel, $totalUsers, $type)
    {
        $islands = array();
        $previousLevelCount = $totalUsers;

        foreach($funnel as $item)
        {
            if(!array_key_exists($item->islandId, $islands))
            {
                $islands[$item->islandId] = array('levels' => array(), 'count' => 0, 'islandId' => $item->islandId);
            }
    
            if($type == 1)
                $diff = $previousLevelCount ? ($item->count / $previousLevelCount) : 0;
            else if($type == 2)
                $diff = $totalUsers ? $item->count / $totalUsers : 0;
        
            $islands[$item->islandId]['levels'][] = 
            array
            (
                'levelId' => $item->levelId, 
                'count' => $item->count, 
                'diff' => $diff
            );
    
            $previousLevelCount = $item->count;
    
            if($islands[$item->islandId]['count'] == 0)
                $islands[$item->islandId]['count'] = $item->count;
        }
        
        return $islands;
    }
}