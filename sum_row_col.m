function B = sum_row_col(A)
%SUM_ROW_COL  Sums row and columns of a matrix.
%
%  B = sum_row_col(A)
%
%  The sums are given in new row and column
%   appended below last row and right of last column of A.

B = [
     A        sum(A,2)
     sum(A,1) sum(A(:))
     ];
