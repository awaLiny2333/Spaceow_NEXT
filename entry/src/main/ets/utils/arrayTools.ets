import { FileObject } from "../objects/FileObject";

export function sortParallelArraysInPlace(
  A: FileObject[],
  B: number[][],
  ascending: boolean = false
): void {

  if (A.length !== B.length) {
    throw new Error("Arrays A and B must be of equal length");
  }

  if (B.some(subArray => subArray.length === 0)) {
    throw new Error("All sub-arrays in B must have at least one element");
  }

  // 创建包含索引的对象数组
  const indices = A.map((_, index) => index);

  // 根据B的子数组的第一个值排序索引
  indices.sort((i, j) =>
  ascending
    ? B[i][0] - B[j][0]
    : B[j][0] - B[i][0]
  );

  // 根据排序后的索引重新排列A和B
  const sortedA = indices.map(i => A[i]);
  const sortedB = indices.map(i => B[i]);

  // 将排序后的值复制回原数组
  for (let i = 0; i < A.length; i++) {
    A[i] = sortedA[i];
    B[i] = sortedB[i];
  }
}