/**
 * @name orderTrigger
 * @description
**/
trigger OrderTrigger on Order (after update) {
    if(Trigger.New != null){
        OrderHelper.AfterUpdate(Trigger.new, Trigger.old);
    }
}