import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useLoadingStore } from '../loading'

describe('loadingStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('should have correct initial state', () => {
    const store = useLoadingStore()
    expect(store.isLoading).toBe(false)
    expect(store.loadingCount).toBe(0)
  })

  it('should start a loading operation', () => {
    const store = useLoadingStore()
    store.startLoading('test-operation')

    expect(store.isLoading).toBe(true)
    expect(store.loadingCount).toBe(1)
    expect(store.isOperationLoading('test-operation')).toBe(true)
  })

  it('should stop a loading operation', () => {
    const store = useLoadingStore()
    store.startLoading('test-operation')
    store.stopLoading('test-operation')

    expect(store.isLoading).toBe(false)
    expect(store.loadingCount).toBe(0)
    expect(store.isOperationLoading('test-operation')).toBe(false)
  })

  it('should handle multiple loading operations', () => {
    const store = useLoadingStore()
    store.startLoading('operation-1')
    store.startLoading('operation-2')
    store.startLoading('operation-3')

    expect(store.isLoading).toBe(true)
    expect(store.loadingCount).toBe(3)

    store.stopLoading('operation-1')
    expect(store.isLoading).toBe(true)
    expect(store.loadingCount).toBe(2)

    store.stopLoading('operation-2')
    store.stopLoading('operation-3')
    expect(store.isLoading).toBe(false)
    expect(store.loadingCount).toBe(0)
  })

  it('should clear all loading operations', () => {
    const store = useLoadingStore()
    store.startLoading('operation-1')
    store.startLoading('operation-2')
    store.startLoading('operation-3')

    store.clearAllLoading()

    expect(store.isLoading).toBe(false)
    expect(store.loadingCount).toBe(0)
  })

  it('should return false for non-existent operation', () => {
    const store = useLoadingStore()
    expect(store.isOperationLoading('non-existent')).toBe(false)
  })
})
