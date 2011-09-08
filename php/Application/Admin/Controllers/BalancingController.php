<?php
/**
 * @category       Application
 * @package        Application_Controllers
 * @author         Bartosz Szymanski
 */

class Admin_BalancingController extends Application_Admin_Controllers_AuthController
{
    public function init()
    {
        $this->view->section = 'balancing';
        $this->_redirector   = $this->_helper->getHelper('Redirector');
    }

    public function indexAction()
    {
        $this->_redirect('/admin/balancing/premiumitems');
    }
    
    public function premiumitemsAction()
    {
        $this->view->module       = 'premiumitems';
        $this->view->secondaryNav = $this->view->render("balancing/secondary-nav.phtml");
        
        $premiumItemsMapper = new Application_Models_Mappers_PremiumItems();
        $premiumItems       = $premiumItemsMapper->fetchAll();
        
        $this->view->premiumItems  = $premiumItems;
        $this->view->fieldsDisplay = array(
            "title" => "Title",
            "price" => "Price",
            "description" => "Description",
            "image_url" => "Image"
        );
    }
    
    public function boostersAction()
    {
        $this->view->module       = 'boosters';
        $this->view->secondaryNav = $this->view->render("balancing/secondary-nav.phtml");
        
        $boostersMapper = new Application_Models_Mappers_Boosters();
        $boosters       = $boostersMapper->fetchAll();
        
        $this->view->boosters      = $boosters;
        $this->view->fieldsDisplay = array(
            "name" => "Name",
            "cost" => "Price",
            "value" => "Value",
            "quantity" => "Quantity"
        );
    }
    
    public function removeboosterAction()
    {
        $this->getHelper('viewRenderer')->setNoRender();
        
        $boostersMapper = new Application_Models_Mappers_Boosters();
        $booster        = new Application_Models_Booster();
        
        $booster->typeId = $this->getRequest()->getParam("typeId");
        $booster         = $boostersMapper->load($booster);
        
        $boostersMapper->delete($booster);

        $this->_redirector->gotoUrl('/admin/balancing/boosters');
    }
    
    public function editboosterAction()
    {
        $this->view->module       = 'boosters';
        $this->view->secondaryNav = $this->view->render("balancing/secondary-nav.phtml");
        
        $typeId         = $this->getRequest()->getParam("typeId");
        $boostersMapper = new Application_Models_Mappers_Boosters();
        
        $fields = array(
            "name" => "Name",
            "cost" => "Price in fb credits",
            "quantity" => "Number of boosters in package",
            "value" => "Number of uses per game",
            "typeId" => null
        );
        
        if($this->getRequest()->isPost())
        {
            if($this->getRequest()->getParam("save"))
            {
                $booster = new Application_Models_Booster();
                
                foreach($fields as $fieldKey => $fieldDesc)
                {
                    $val = $this->getRequest()->getParam($fieldKey);
                    
                    if($val == "")
                        $val = null;
                    
                    $booster->{$fieldKey} = $val;
                }

                $boostersMapper->save($booster);
            }

            $this->_redirector->gotoUrl('/admin/balancing/boosters');
        }

        $editForm = new Application_Admin_Form_StandardEdit($fields, array("typeId" => $typeId));
        $booster  = $boostersMapper->find($typeId);
        
        $editForm->populate((array)$booster);
        
        $this->view->editForm        = $editForm;
        $this->view->itemDisplayName = $booster ? $booster->name : null;
        $this->view->isAddNewForm    = $booster == null;
    }
    
    public function unlockablesAction()
    {
        $this->view->module       = 'unlockables';
        $this->view->secondaryNav = $this->view->render("balancing/secondary-nav.phtml");
        
        $unlockablesMapper = new Application_Models_Mappers_Unlockables();
        $unlockables       = $unlockablesMapper->fetchAll();
        
        $this->view->unlockables   = $unlockables;
        $this->view->fieldsDisplay = array(
            "typeId" => "Type id",
             "requiredQty" => "Required value",
            "reward" => "Reward",
            "desc" => "Description"
        );
    }
    
    public function editunlockableAction()
    {
        $fields = array( 
            "requiredQty" => "Required value", 
            "reward" => "Reward", 
            "desc" => "Description",
            "typeId" => null
        );

        $typeId            = $this->getRequest()->getParam("typeId");
        $unlockablesMapper = new Application_Models_Mappers_Unlockables();

        if($this->getRequest()->isPost())
        {
            if($this->getRequest()->getParam("save"))
            {
                $unlockable = new Application_Models_Unlockable();

                foreach($fields as $field => $label)
                {
                    $val = $this->getRequest()->getParam($field);

                    if($val == "")
                    {
                        $val = null;
                    }
                    
                    $unlockable->{$field} = $val;
                }

                $unlockablesMapper->save($unlockable);
            }

            $this->_redirector->gotoUrl('/admin/balancing/unlockables');
        }

        $editForm   = new Application_Admin_Form_StandardEdit($fields, array("typeId" => $typeId));
        $unlockable = $unlockablesMapper->find($typeId);
        
        $editForm->populate((array)$unlockable);
        
        $this->view->editForm        = $editForm;
        $this->view->itemDisplayName = $unlockable ? $unlockable->desc : null;
        $this->view->isAddNewForm    = $unlockable == null;
    }
    
    public function removeunlockableAction()
    {
        $this->getHelper('viewRenderer')->setNoRender();
        $unlockablesMapper = new Application_Models_Mappers_Unlockables();
        
        $unlockable = new Application_Models_Unlockable();
        $unlockable->typeId = $this->getRequest()->getParam("typeId");
        $unlockable = $unlockablesMapper->load($unlockable);
        
        $unlockablesMapper->delete($unlockable);

        $this->_redirector->gotoUrl('/admin/balancing/unlockables');
    }
    
    public function editpremiumitemAction()
    {
        $fields = array(
            "type" => "Type id",
            "value" => "Value (e.g. number of lifes)",
            "title" => "Title",
            "price" => "Price in fb credits",
            "bonus" => "Bonus (e.g. number of gratis lifes)",
            "description" => "Description",
            "image_url" => "Image url",
            "product_url" => "Product url",
            "item_id" => null
        );
        
        $this->view->module       = 'premiumitems';
        $this->view->secondaryNav = $this->view->render("balancing/secondary-nav.phtml");
        
        $item_id            = $this->getRequest()->getParam("item_id");
        $premiumItemsMapper = new Application_Models_Mappers_PremiumItems();

        if($this->getRequest()->isPost())
        {
            if($this->getRequest()->getParam("save"))
            {
                $premiumItem = new Application_Models_PremiumItem();

                foreach($fields as $field => $label)
                {
                    $val = $this->getRequest()->getParam($field);

                    if($val == "")
                        $val = null;
                    
                    $premiumItem->{$field} = $val;
                }

                $premiumItemsMapper->save($premiumItem);
            }
            
            $this->_redirector->gotoUrl('/admin/balancing/premiumitems');
        }

        $editForm    = new Application_Admin_Form_StandardEdit($fields, array("item_id" => $item_id));
        $premiumItem = $premiumItemsMapper->find($item_id);
        
        $editForm->populate((array)$premiumItem);
        
        $this->view->editForm        = $editForm;
        $this->view->itemDisplayName = $premiumItem ? $premiumItem->title : null;
        $this->view->isAddNewForm    = $premiumItem == null;
    }
    
    public function removepremiumitemAction()
    {
        $this->getHelper('viewRenderer')->setNoRender();
        
        $premiumItemsMapper = new Application_Models_Mappers_PremiumItems();
        $premiumItem        = new Application_Models_PremiumItem();
        
        $premiumItem->item_id = $this->getRequest()->getParam("item_id");
        $premiumItem          = $premiumItemsMapper->load($premiumItem);
        
        $premiumItemsMapper->delete($premiumItem);

        $this->_redirector->gotoUrl('/admin/balancing/premiumitems');
    }
}