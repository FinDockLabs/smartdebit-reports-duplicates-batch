public class MarkDuplicateIrsBatch implements Database.Batchable<AggregateResult>{
    public Iterable<AggregateResult> start(Database.BatchableContext bc){
        String query = 'SELECT cpm__Checksum__c,count(id) FROM cpm__inbound_report__c WHERE cpm__Status__c <> \'duplicate\' AND cpm__Checksum__c <> \'\'  AND cpm__report_type__c = \'BACS\' GROUP BY cpm__Checksum__c HAVING count(id)>1';
        return new AggregateResultIterable(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){ 
       
        List<AggregateResult> aggr = new List<AggregateResult>();

        for(sObject sObj : scope) {
            aggr.add((AggregateResult)sObj);
        }
            
        List<String> badChecksums = new List<String>();
        for (AggregateResult ar : aggr) {
            badChecksums.add((String) ar.get('cpm__Checksum__c'));
        }
        
        if (!badChecksums.isEmpty()) {
            // Query the IR records with duplicate checksums
            List<cpm__inbound_report__c> irList = [
                SELECT Id, cpm__Checksum__c, cpm__Status__c, CreatedDate
                FROM cpm__inbound_report__c
                WHERE cpm__Checksum__c IN :badChecksums
                AND cpm__Status__c <> 'duplicate'
                ORDER BY cpm__Checksum__c, CreatedDate ASC];
            
            List<cpm__inbound_report__c> irsToMarkDuplicate = new List<cpm__inbound_report__c>();
            String lastChecksum = 'placeholder';
            
            // Mark all but the first IR for each checksum as duplicate
            for (cpm__inbound_report__c ir : irList) {
                if (ir.cpm__Checksum__c == lastChecksum) {
                    ir.cpm__Status__c = 'Duplicate';
                    irsToMarkDuplicate.add(ir);
                }
                lastChecksum = ir.cpm__Checksum__c;
            }
            
            if (!irsToMarkDuplicate.isEmpty()) {
                update irsToMarkDuplicate;
            }
        }
    
    }
    
    public void finish(Database.BatchableContext bc){ 
        System.debug('Batch processing completed');}
}