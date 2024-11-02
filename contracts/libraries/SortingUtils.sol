// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

library SortingUtils {
    function quickSort(
        address[] memory items,
        uint32[] memory scores,
        int256 left,
        int256 right
    ) internal pure {
        int256 i = left;
        int256 j = right;
        uint32 pivot = scores[uint256(left + (right - left) / 2)];
        
        while (i <= j) {
            while (scores[uint256(i)] > pivot) i++;
            while (pivot > scores[uint256(j)]) j--;
            if (i <= j) {
                (items[uint256(i)], items[uint256(j)]) = (items[uint256(j)], items[uint256(i)]);
                (scores[uint256(i)], scores[uint256(j)]) = (scores[uint256(j)], scores[uint256(i)]);
                i++;
                j--;
            }
        }
        
        if (left < j) quickSort(items, scores, left, j);
        if (i < right) quickSort(items, scores, i, right);
    }
}
