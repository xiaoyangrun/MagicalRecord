//
//  Created by Tony Arnold on 25/03/2014.
//  Copyright (c) 2014 Magical Panda Software LLC. All rights reserved.
//

#import "MagicalRecordTestBase.h"
#import "SingleRelatedEntity.h"

@interface NSManagedObjectMagicalRecordTests : MagicalRecordTestBase

@end

@implementation NSManagedObjectMagicalRecordTests

- (void)testCanGetEntityDescriptionFromEntityClass
{
    NSManagedObjectContext *stackContext = self.stack.context;

    NSEntityDescription *testDescription = [SingleRelatedEntity MR_entityDescriptionInContext:stackContext];

    expect(testDescription).toNot.beNil();
}

- (void)testCanCreateEntityInstance
{
    NSManagedObjectContext *stackContext = self.stack.context;

    SingleRelatedEntity *testEntity = [SingleRelatedEntity MR_createEntityInContext:stackContext];

    expect(testEntity).toNot.beNil();
}

- (void)testCanDeleteEntityInstanceInCurrentContext
{
    MagicalRecordStack *currentStack = self.stack;
    NSManagedObjectContext *currentStackContext = currentStack.context;

    NSManagedObject *insertedEntity = [SingleRelatedEntity MR_createEntityInContext:currentStackContext];

    [currentStackContext MR_saveToPersistentStoreAndWait];

    expect([insertedEntity MR_isEntityDeleted]).to.beFalsy();

    [currentStack saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSManagedObject *localEntity = [insertedEntity MR_inContext:localContext];

        expect([localEntity MR_deleteEntityInContext:localContext]).to.beTruthy();
    }];

    // The default context entity should now be deleted
    expect(insertedEntity).willNot.beNil();
    expect([insertedEntity MR_isEntityDeleted]).will.beTruthy();
}

- (void)testCanDeleteEntityInstanceInOtherContext
{
    MagicalRecordStack *currentStack = self.stack;
    NSManagedObjectContext *currentStackContext = currentStack.context;

    NSManagedObject *testEntity = [SingleRelatedEntity MR_createEntityInContext:currentStackContext];

    [currentStackContext MR_saveToPersistentStoreAndWait];

    expect([testEntity MR_isEntityDeleted]).to.beFalsy();

    [currentStack saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSManagedObject *otherEntity = [testEntity MR_inContext:localContext];

        expect(otherEntity).toNot.beNil();
        expect([otherEntity MR_isEntityDeleted]).to.beFalsy();

        // Delete the object in the other context
        expect([testEntity MR_deleteEntityInContext:localContext]).to.beTruthy();

        // The nested context entity should now be deleted
        expect([otherEntity MR_isEntityDeleted]).to.beTruthy();
    }];

    // The default context entity should now be deleted
    expect(testEntity).willNot.beNil();
    expect([testEntity MR_isEntityDeleted]).will.beTruthy();
}

- (void)testThatRetrievingManagedObjectFromAnotherContextHasAPermanentObjectID
{
    MagicalRecordStack *currentStack = self.stack;
    NSManagedObjectContext *currentStackContext = currentStack.context;

    NSManagedObject *insertedEntity = [SingleRelatedEntity MR_createEntityInContext:currentStackContext];

    expect([[insertedEntity objectID] isTemporaryID]).to.beTruthy();

    [currentStack saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSManagedObject *localEntity = [insertedEntity MR_inContext:localContext];

        expect([[localEntity objectID] isTemporaryID]).to.beFalsy();
    }];

    expect([[insertedEntity objectID] isTemporaryID]).to.beFalsy();
}

@end
