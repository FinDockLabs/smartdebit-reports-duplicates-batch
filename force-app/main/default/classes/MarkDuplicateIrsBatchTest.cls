@isTest
private class MarkDuplicateIrsBatchTest {
    
    @testSetup
    static void setupTestData() {
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
        
        // Create duplicate inbound report records for CHK001 and CHK003
        List<cpm__inbound_report__c> dupList = new List<cpm__inbound_report__c>{
            new cpm__inbound_report__c(
                cpm__Checksum__c = 'CHK001', 
                cpm__Status__c = 'Guided Review', 
                cpm__report_type__c = 'BACS'
            ),
            new cpm__inbound_report__c(
                cpm__Checksum__c = 'CHK001', 
                cpm__Status__c = 'Guided Review', 
                cpm__report_type__c = 'BACS'
            ),
            new cpm__inbound_report__c(
                cpm__Checksum__c = 'CHK003', 
                cpm__Status__c = 'Guided Review', 
                cpm__report_type__c = 'BACS'
            ),
            new cpm__inbound_report__c(
                cpm__Checksum__c = 'CHK003', 
                cpm__Status__c = 'Guided Review', 
                cpm__report_type__c = 'BACS'
            )
        };
        insert dupList;
       
        // Make the original record for CHK001 the oldest:
        for(cpm__inbound_report__c ir : [SELECT Id, cpm__Checksum__c 
                                         FROM cpm__inbound_report__c 
                                         WHERE cpm__Checksum__c = 'CHK001' 
                                         ORDER BY CreatedDate ASC]) {
                // oldest record gets a created date 2 days ago
                if(ir.Id == irList[0].Id) {
                    Test.setCreatedDate(ir.Id, System.now().addDays(-2));
                }    
        }
        // Make the original record for CHK003 the oldest:
        for(cpm__inbound_report__c ir : [SELECT Id, cpm__Checksum__c 
                                         FROM cpm__inbound_report__c 
                                         WHERE cpm__Checksum__c = 'CHK003' 
                                         ORDER BY CreatedDate ASC]) {
                // oldest record gets a created date 2 days ago
                if(ir.Id == irList[0].Id) {
                    Test.setCreatedDate(ir.Id, System.now().addDays(-2));
                }    
        }
    }
    
    @isTest
    static void testBatchExecution() {
        
        Test.startTest();
        MarkDuplicateIRsBatch batchJob = new MarkDuplicateIRsBatch();
        Database.executeBatch(batchJob, 200);
        Test.stopTest();
        
        // Query records that should have been updated to 'Duplicate'
        List<cpm__inbound_report__c> chk001Records = [
            SELECT Id, cpm__Checksum__c, cpm__Status__c, CreatedDate
            FROM cpm__inbound_report__c 
            WHERE cpm__Checksum__c = 'CHK001'
            ORDER BY CreatedDate ASC
        ];
        Assert.areEqual(3, chk001Records.size(), 'There should be 3 records for CHK001');
        Assert.areEqual('Guided Review', chk001Records[0].cpm__Status__c, 'The oldest CHK001 record should remain in Guided Review');
        Assert.areEqual('Duplicate', chk001Records[1].cpm__Status__c, 'Subsequent CHK001 record should be marked Duplicate');
        Assert.areEqual('Duplicate', chk001Records[2].cpm__Status__c, 'Subsequent CHK001 record should be marked Duplicate');
        
        // For CHK003, expect the first record remains 'Guided Review' and the second is marked as Duplicate.
        List<cpm__inbound_report__c> chk003Records = [
            SELECT Id, cpm__Checksum__c, cpm__Status__c, CreatedDate
            FROM cpm__inbound_report__c 
            WHERE cpm__Checksum__c = 'CHK003'
            ORDER BY CreatedDate ASC
        ];
        Assert.areEqual(2, chk003Records.size(), 'There should be 2 records for CHK003');
        Assert.areEqual('Guided Review', chk003Records[0].cpm__Status__c, 'The oldest CHK003 record should remain in Guided Review');
        Assert.areEqual('Duplicate', chk003Records[1].cpm__Status__c, 'The newer CHK003 record should be marked Duplicate');
        
        // Ensure that records with unique checksums remain unchanged 
        cpm__inbound_report__c uniqueRecord = [
            SELECT cpm__Status__c FROM cpm__inbound_report__c 
            WHERE cpm__Checksum__c = 'CHK002'
            LIMIT 1
        ];
        Assert.areEqual('Guided Review', uniqueRecord.cpm__Status__c, 'Unique record should remain unchanged');
    }
    
}