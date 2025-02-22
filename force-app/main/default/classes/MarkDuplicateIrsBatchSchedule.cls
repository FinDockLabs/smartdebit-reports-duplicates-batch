global class MarkDuplicateIrsBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc){
        MarkDuplicateIrsBatch batch = new MarkDuplicateIrsBatch();
        Database.executeBatch(batch,200);
    }
}