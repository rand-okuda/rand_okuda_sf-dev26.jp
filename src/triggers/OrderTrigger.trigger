trigger OrderTrigger on Order (after delete, after update) {

    // When an order is created.
    if (Trigger.isAfter && Trigger.isUpdate){
        // Create a list of Order records.
        List<Order> orderList = new List<Order>();
        for (Order order :Trigger.new){
            orderList.add(order);
        }
        // Pass the list to the processing class.
        if (!orderList.isEmpty()){
            updatePub.setAccountCurrentBalance(orderList);
        }
    }
    
    // When an order is deleted.
    if (Trigger.isAfter && Trigger.isDelete){
        // Create a list of Order records.
        List<Order> orderList = new List<Order>();
        for (Order order :Trigger.old){
            orderList.add(order);
        }
        // Pass the list to the processing class.
        if (!orderList.isEmpty()){
            updatePub.setAccountCurrentBalance(orderList);
        }
    }
    
}