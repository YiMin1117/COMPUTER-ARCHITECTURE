#include <stdio.h>
#include <math.h>

// 結構體來保存點和對應的距離
typedef struct {
    float x;
    float y;
    float distance;  // 點到原點的距離
} Point;

// 函數聲明
float calculateDistance(float x, float y);
void quicksort(Point points[], int low, int high);
int partition(Point points[], int low, int high);

// 計算每個點到原點的歐幾里得距離
float calculateDistance(float x, float y) {
    return sqrt(x * x + y * y);
}

// 快速排序，按照距離從小到大排序
void quicksort(Point points[], int low, int high) {
    if (low < high) {
        int pivot = partition(points, low, high);
        quicksort(points, low, pivot - 1);
        quicksort(points, pivot + 1, high);
    }
}

// 劃分函數，用於快速排序
int partition(Point points[], int low, int high) {
    float pivot = points[high].distance;
    int i = low - 1;

    for (int j = low; j < high; j++) {
        if (points[j].distance <= pivot) {
            i++;
            Point temp = points[i];
            points[i] = points[j];
            points[j] = temp;
        }
    }

    Point temp = points[i + 1];
    points[i + 1] = points[high];
    points[high] = temp;

    return i + 1;
}

// 找到距離原點最近的 K 個點
void kClosestPoints(Point points[], int num_points, int k) {
    // 首先計算每個點的距離
    for (int i = 0; i < num_points; i++) {
        points[i].distance = calculateDistance(points[i].x, points[i].y);
    }

    // 使用快速排序來按距離排序
    quicksort(points, 0, num_points - 1);

    // 打印最近的 K 個點
    printf("The %d closest points to the origin are:\n", k);
    for (int i = 0; i < k; i++) {
        printf("Point (%.2f, %.2f), Distance: %.2f\n", points[i].x, points[i].y, points[i].distance);
    }
}

// 主函數，執行不同的測試數據
int main() {
    // Test 1
    Point points1[] = {{1.1, 2.2}, {3.0, 3.0}, {5.5, 1.1}, {0.2, 0.8}, {4.4, 3.3}};
    int k1 = 3;
    kClosestPoints(points1, 5, k1);

    // Test 2
    Point points2[] = {{1.5, 2.5}, {2.0, 2.0}, {3.5, 1.2}, {4.8, 2.1}, {5.0, 0.5}, {1.0, 1.0}};
    int k2 = 4;
    kClosestPoints(points2, 6, k2);

    // Test 3
    Point points3[] = {{2.2, 2.2}, {3.1, 4.5}, {1.0, 1.0}, {0.5, 0.5}};
    int k3 = 2;
    kClosestPoints(points3, 4, k3);

    return 0;
}
