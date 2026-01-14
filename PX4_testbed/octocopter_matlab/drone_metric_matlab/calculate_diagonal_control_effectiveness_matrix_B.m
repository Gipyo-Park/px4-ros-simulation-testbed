function [B] = calculate_diagonal_control_effectiveness_matrix_B(B)
    
%{
    df_du = B =
    [  0,      0,       0,       0]
    [  0,      0,       0,       0]
    [  0,      0,       0,       0]
    [  0,      0,       0,       0]
    [  0,      0,       0,       0]
    [2/3,      0,       0,       0]
    [  0,      0,       0,       0]
    [  0,      0,       0,       0]
    [  0,      0,       0,       0]
    [  0, 50/373,       0,       0]
    [  0,      0, 100/153,       0]
    [  0,      0,       0, 100/889]
%}
    disp('first B = ')
    disp(B)
    % Extract specific values to create a diagonal matrix
    B_6_1 = B(6,1);
    B_10_2 = B(10,2);
    B_11_3 = B(11,3);
    B_12_4 = B(12,4);
    
    % Create a diagonal matrix from the extracted values
    B_temp = diag([B_6_1, B_10_2, B_11_3, B_12_4]);
    inv_B_temp = inv(B_temp);

    B(6,1) = inv_B_temp(1,1);
    B(10,2) = inv_B_temp(2,2);
    B(11,3) = inv_B_temp(3,3);
    B(12,4) = inv_B_temp(4,4);

    disp('final B = ')
    disp(B)
    
end