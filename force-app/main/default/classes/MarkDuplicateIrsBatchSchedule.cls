public class MarkDuplicateIrsBatchSchedule implements Schedulable {
    public void execute(SchedulableContext sc){
        MarkDuplicateIrsBatch batch = new MarkDuplicateIrsBatch();
        Database.executeBatch(batch,200);
    }
}