global class MarkDuplicateIrsBatch implements Database.Batchable<AggregateResult>{
    global Iterable<AggregateResult> start(Database.BatchableContext bc){
        String query = 'SELECT cpm__Checksum__c,count(id) FROM cpm__inbound_report__c WHERE cpm__Status__c <> \'duplicate\' AND cpm__Checksum__c <> \'\'  AND cpm__report_type__c = \'BACS\' GROUP BY cpm__Checksum__c HAVING count(id)>1';
        return new AggregateResultIterable(query);
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){ 
        System.debug('number of checksums:' + scope.size());
        List<AggregateResult> aggr = new List<AggregateResult>();

        for(sObject sObj : scope) {
            aggr.add((AggregateResult)sObj);
        }
        System.debug(' COUNT : ' + aggr.size());
            
        List<String> badChecksums = new List<String>();
        for (AggregateResult ar : aggr) {
            badChecksums.add((String) ar.get('cpm__Checksum__c'));
        }
        system.debug('Total number of checksums to process'+badChecksums.size());
        
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
            System.debug('Number of IRs to update'+irsToMarkDuplicate.size());
            
            if (!irsToMarkDuplicate.isEmpty()) {
                update irsToMarkDuplicate;
            }
        }
    
    }
    
    global void finish(Database.BatchableContext bc){ 
        System.debug('Batch processing completed');}
}