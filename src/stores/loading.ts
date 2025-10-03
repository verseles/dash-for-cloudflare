import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useLoadingStore = defineStore('loading', () => {
  // Map to track multiple loading operations
  const loadingOperations = ref(new Map<string, boolean>());

  // General loading state (true if any operation is loading)
  const isLoading = computed(() => {
    return Array.from(loadingOperations.value.values()).some((loading) => loading);
  });

  // Start a loading operation
  function startLoading(operationId: string) {
    loadingOperations.value.set(operationId, true);
  }

  // Stop a loading operation
  function stopLoading(operationId: string) {
    loadingOperations.value.delete(operationId);
  }

  // Check if a specific operation is loading
  function isOperationLoading(operationId: string): boolean {
    return loadingOperations.value.get(operationId) || false;
  }

  // Clear all loading operations
  function clearAllLoading() {
    loadingOperations.value.clear();
  }

  // Get count of active loading operations
  const loadingCount = computed(() => loadingOperations.value.size);

  return {
    isLoading,
    loadingCount,
    startLoading,
    stopLoading,
    isOperationLoading,
    clearAllLoading,
  };
});
