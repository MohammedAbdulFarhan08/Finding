I’m adding the secret inventory doc (pipeline-secrets-inventory.md, the genericized version) into the repo as its own MR, into the documentation/infrastructure/ keys/secrets path that John is adding via his STS keys doc merge.

Workflow (my standard): first pull main to refresh and pick up John’s merged STS doc + the new documentation/infrastructure keys path. Then copy main into a new ticket folder — use the folder/branch name c5425849-secret-inventory-doc (do NOT work in ~/main or default to any other name). Create the feature branch c5425849-secret-inventory-doc there.

Then place the genericized inventory doc into the correct documentation/infrastructure/ location (match the exact path/naming John’s STS doc uses — check where his merged doc landed first so mine sits alongside it consistently). Don’t invent a path; use the one his merge created.

Stop and show me the diff + the target path before committing. Don’t raise the MR yet — I’ll review placement first.
