# SwiftUI Network Architecture

A clean, testable network architecture pattern for SwiftUI applications using MVVM and dependency injection.

## Key Features

- **Protocol-based NetworkManager** - Easy to mock for testing  
- **ViewModel with @MainActor** - Handles UI state and business logic  
- **Published Properties** - Reactive UI updates  
- **Dependency Injection** - Loosely coupled, testable components  
- **Error Handling** - Built-in loading and error states  

## Usage

### In Your View

The ViewModel handles all complexity while keeping your view simple and declarative:

```swift
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        // Your UI code here
    }
}
```

The `@StateObject` creates and manages the ViewModel lifecycle automatically.

## Testing

Easily create a `MockNetworkManager` that implements `NetworkManagerProtocol` for comprehensive testing:

- Success scenarios  
- Failure handling  
- Loading states  
- Network timeouts  

## Benefits

- **Separation of Concerns** - View handles UI, ViewModel handles business logic  
- **Reactive UI** - Automatic updates when data changes  
- **Loading States** - Built-in loading and error handling  
- **Testable** - Unit test without UI dependencies  

## Summary

This architecture allows you to test network logic, error handling, and state management independently of the UI, making your code more reliable and maintainable.


# 🎯 Custom Drag & Drop Implementation

## 1. DragDropState Manager

- **Centralised State:** Manages drag state across all cards  
- **Real-time Updates:** Tracks which item is being dragged  
- **Target Detection:** Identifies drop targets during drag operations  

## 2. DraggablePictureCard Component

- **Visual Feedback:** Cards scale up and show a shadow when dragged  
- **Smooth Animations:** Spring animations for natural feel  
- **Position Calculation:** Smart algorithm to determine new position based on drag distance  
- **Gesture Integration:** Uses `DragGesture` with proper state management  

## 3. Enhanced Visual Indicators

- **Improved Drag Handle:** More prominent design with background highlight  
- **"Drag" Label:** Clear instruction text below the handle  
- **Dynamic Scaling:** Cards grow slightly when being dragged  
- **Shadow Effects:** Blue shadow appears during drag for better visual feedback  

---

# 🔧 How It Works

- **Start Drag:**  drag on any card Drag handle begins the operation  
- **Visual Feedback:** Card scales up (1.05x) with blue shadow  
- **Position Tracking:** Calculates target position based on vertical drag distance  
- **Smart Reordering:** Automatically determines the best insertion point  
- **Smooth Animation:** Spring animations for natural movement  

---

# ✨ Key Features

- **Intuitive Interaction:** Just drag any Drag handle up or down  
- **Visual Clarity:** Clear drag handles with instructions  
- **Responsive Design:** Works in both light and dark modes  
- **Proper State Management:** No conflicts between multiple drag operations  
- **Smooth Performance:** Optimized for fluid interactions  

---

# 🎨 Visual Improvements

- **Enhanced Drag Handle:** Now has a subtle background and clearer "Drag" label  
- **Better Proportions:** Improved spacing and sizing  
- **Dark Mode Support:** All drag elements work perfectly in both themes  

---

Now you can drag any picture card up or down to reorder them in your collection! The drag handle is visible on the right side of each card with proper instructions.


I've created comprehensive test suites for  `PicturesViewModel` and `NetworkManager`. Here's what I've provided:

## Test Files Created

### 1. PicturesViewModelTests.swift

- **Initialization Tests:** Verify proper setup  
- **Fetch Tests:** Success, failure, no duplicates, correct ordering  
- **Delete Tests:** By index and by ID, including edge cases  
- **Move Tests:** Reordering and same-position moves  
- **Refresh Tests:** Pull-to-refresh functionality  
- **Loading States:** Verify UI states during operations  

### 2. NetworkManagerTests.swift

- **Success Cases:** Valid JSON, empty responses  
- **Error Cases:** Network errors, no data, invalid JSON, various HTTP status codes  
- **Response Handler Tests:** All HTTP status code ranges  
- **Mock Implementation:** Testable version of NetworkManager  

### 3. PicturesIntegrationTests.swift

- **Complete User Workflows:** End-to-end scenarios  
- **Error Recovery:** Network failure and recovery  
- **Large Dataset Handling:** Performance with many items  
- **Concurrent Operations:** Multiple simultaneous requests  
- **Persistence Scenarios:** Data saving/loading  
- **Edge Cases:** Empty states, invalid indices  
- **Performance Tests:** Memory and speed benchmarks  

---

## Key Testing Areas Covered

### ✅ Happy Path Scenarios

- Successful data fetching  
- Picture management (add, delete, move)  
- Refresh operations  

### ✅ Error Handling

- Network failures  
- Invalid JSON responses  
- HTTP error codes (401, 404, 500, etc.)  
- No data scenarios  

### ✅ Edge Cases

- Empty datasets  
- Duplicate prevention  
- Large datasets (1000+ items)  
- Concurrent operations  
- Invalid indices/IDs  

### ✅ Performance Testing

- Memory management  
- Large dataset operations  
- Rapid user interactions  

### ✅ Integration Testing

- Complete user workflows  
- Error recovery scenarios  
- Persistence behavior  


