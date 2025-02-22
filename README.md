<a href="https://githubsfdeploy.herokuapp.com?owner=FinDockLabs&repo=findock-reconciliation-markDuplicateIRsBACS&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

```text
NOTE: to be able to deploy this project to your Salesforce production environment your overall test code coverage needs to meet Salesforce thresholds.
Although this project has 100% coverage, existing custom code in your environment might push the overall coverage below the threshold. 
```

# FinDock Reconciliation Mark BACS IRs Duplicate

With Smart Debit automated reports we poll for BACS reports daily, these reports will duplicate for a few days while they are still available within the poll request. We already ensure that no action is taken on duplicates. This project contains a Batch apex class that can be scheduled to run regularly and set Inbound Reports to a status of "Duplicate" so you can recognise them. 

## Full list of components

```text
**apexclass**
classes/AggregateResultIterable.cls
classes/AggregateResultIterator.cls
classes/MarkDuplicateIrsBatch.cls
classes/MarkDuplicateIrsBatchSchedule.cls
classes/MarkDuplicateIrsBatchScheduleTest.cls
classes/MarkDuplicateIrsBatchTest.cls

**scripts**
scripts/apex/ScriptToRunMarkDuplicatesBatchApex
```

## Installation
- use `sfdx` to deploy a selection of or all components.
- press the "Deploy to Salesforce" button at the top of this README and then press "Login to Salesforce" in the top right of your screen. Please note, the GitHub Salesforce Deploy Tool is provided open source by [andyinthecloud](http://andyinthecloud.com/category/githubsfdeploy/). No FinDock support is provided.
- any other deployment method you prefer.

## Configuration
- Schedule the class "MarkDuplicateIrsBatchSchedule" to run on a regular basis. We recommend running this daily. 
- To run this on a one-time basis : from the Developer Console, run the anonymous apex that you can find at the following path in this project - scripts/apex/ScriptToRunMarkDuplicatesBatchApex

## Contributing

When contributing to this repository, please first discuss the change you wish to make via an issue or any other method with FinDock before making a change.

## Support

FinDock Labs is a non-supported group in FinDock that releases applications. Despite the name, assistance for any of these applications is not provided by FinDock Support because they are not officially supported features. For a list of these apps, visit the FinDock Labs account on Github.

## License

This project is licensed under the MIT License - see the [LICENSE](/LICENSE) file for details