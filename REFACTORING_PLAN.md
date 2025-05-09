# State Management Consolidation Plan

## Current Issues
1. **Duplicated Cubit Code**: All the classes in `mdb_cubits.dart` follow a similar pattern with repeated utility methods
2. **Inconsistent State Management**: Some cubits use Freezed while others use custom classes
3. **Organization**: All sync cubits are kept in a single file, making it hard to maintain
4. **Redis Efficiency**: Current implementation makes individual Redis calls for each property, causing unnecessary overhead

## Proposed Changes

### 1. Optimize Redis Operations with MULTI/EXEC
- Refactor the `SyncableCubit` to use Redis MULTI/EXEC for batched operations
- Group related Redis calls to reduce network overhead and improve performance
- Implement batch fetching of properties when initializing or refreshing state

```dart
// Example of optimized Redis fetching in SyncableCubit
Future<void> batchRefresh(List<String> variables) async {
  final command = await redisRepository.getConnection();
  try {
    // Start a MULTI transaction
    await command.send_object(["MULTI"]);
    
    // Queue up multiple HGET operations
    for (final variable in variables) {
      await command.send_object(["HGET", state.syncSettings.channel, variable]);
    }
    
    // Execute transaction
    final results = await command.send_object(["EXEC"]);
    
    // Process results
    if (results is List && results.length == variables.length) {
      T newState = state;
      for (int i = 0; i < variables.length; i++) {
        if (results[i] != null) {
          newState = newState.update(variables[i], results[i].toString());
        }
      }
      emit(newState);
    }
  } finally {
    redisRepository.releaseConnection(command);
  }
}
```

### 2. Create a Base SyncCubit Class With Helper Methods
Create a generic base class with common functionality shared by all sync cubits:

```dart
abstract class BaseSyncCubit<T extends Syncable<T>> extends SyncableCubit<T> {
  // Shared static and instance methods 
  static T watchData<C extends BaseSyncCubit<T>, T>(BuildContext context) {
    return context.watch<C>().state;
  }
  
  static T selectData<C extends BaseSyncCubit<T>, T, R>(
    BuildContext context, 
    R Function(T) selector
  ) {
    return selector(context.select((C cubit) => cubit.state));
  }
  
  // Group properties that should be fetched together for efficiency
  final List<String> batchProperties;
  
  BaseSyncCubit(MDBRepository repo, T initialState, {this.batchProperties = const []}) 
      : super(redisRepository: repo, initialState: initialState);
      
  @override
  void start() {
    // If we have batch properties defined, use optimized fetching
    if (batchProperties.isNotEmpty) {
      batchStart();
    } else {
      // Fall back to original implementation for backward compatibility
      super.start();
    }
  }
  
  // Optimized start method using batched Redis operations
  void batchStart() {
    // Implementation using MULTI/EXEC pattern
  }
}
```

### 3. Split mdb_cubits.dart Into Individual Files
- Create a new `cubits/sync` directory
- Create individual files for each cubit, following a consistent pattern
- Group related cubits that access the same Redis channel (e.g., battery cubits)

### 4. Standardize on Freezed for State Classes
- Migrate all state classes to use Freezed for consistency
- Define a clear pattern for state updates

## Implementation Steps

### Step 1: Optimize Redis Operations
1. Enhance `MDBRepository` with batched operation support
2. Add MULTI/EXEC transaction support to the Redis connection pool
3. Refactor `SyncableCubit` to support batched operations

### Step 2: Create Base Infrastructure
1. Create `cubits/sync/base_sync_cubit.dart` with common functions and batch support
2. Create directory structure for individual cubit files

### Step 3: Group Related Cubits
1. Identify cubits that access the same Redis channel or logically belong together
2. Plan batch property groups for efficient fetching

### Step 4: Migrate Cubits
1. Start with cubits that would benefit most from batched operations
2. Implement the new pattern with batched property fetching
3. Create individual files in `cubits/sync` for each cubit

### Step 5: Update References and Standardize on Freezed
1. Update imports in all files that reference mdb_cubits.dart
2. Gradually migrate state classes to use Freezed

## Benefits
1. **Redis Efficiency**: Significant reduction in Redis calls through batched operations
2. **Reduced Network Overhead**: Fewer round-trips to Redis for fetching multiple properties
3. **Maintainability**: Each cubit has its own file with clear responsibilities
4. **Performance**: Less CPU and network usage, especially during initialization

## Measurement and Verification
1. Add Redis operation counters to measure performance improvements
2. Implement logging for Redis transactions to verify batching is working correctly
3. Compare performance metrics before and after changes