@isTest
public class MarkDuplicateIrsBatchScheduleTest {
    @isTest
    static void testScheduledBatchExecution() {
        // Create test data
        List<cpm__inbound_report__c> irList = new List<cpm__inbound_report__c>{
            new cpm__inbound_report__c(
                cpm__Checksum__c = 'CHK001', 
                cpm__Status__c = 'Guided Review', 
                cpm__report_type__c = 'BACS'
            ),
            new cpm__inbound_report__c(
                cpm__Checksum__c = 'CHK002', 
                cpm__Status__c = 'Guided Review', 
                cpm__report_type__c = 'BACS'
            )
        };
        insert irList;
        Test.setCreatedDate(irList[0].Id, System.now().addDays(-2));
        
        List<cpm__inbound_report__c> dupList = new List<cpm__inbound_report__c>{
            new cpm__inbound_report__c(
                cpm__Checksum__c = 'CHK001', 
                cpm__Status__c = 'Guided Review', 
                cpm__report_type__c = 'BACS'
            )
         };
        insert dupList;

        // Schedule the job
        String jobId = System.schedule('Test Job', '0 0 0 1 * ?', new MarkDuplicateIrsBatchSchedule());
        System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');
        
        Test.startTest();
        // Execute the scheduled job
        MarkDuplicateIrsBatchSchedule scheduler = new MarkDuplicateIrsBatchSchedule();
		scheduler.execute(null);
        Test.stopTest();
        
        // Verify batch execution
        Integer duplicateCount = [SELECT COUNT() FROM cpm__inbound_report__c WHERE cpm__Status__c = 'Duplicate'];
        System.assert(duplicateCount == 1, 'One record should be marked as duplicate');
    }
}