import csv

# G1 = X^10 + x^3 + 1
# G2 = X^10 + X^9 + X^8 + X^3 + X^2 + 1

def first_ten_octal(expanded, tap0, tap1, init):
    g1 = [None, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

    if expanded:
        g2 = [int(i) for i in bin(init)[2:].zfill(10)]
        g2 = g2[::-1]
        g2.insert(0, None)
    else:
        g2 = [None, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

    chip=[]

    for chips in range(10):
        g1_out = g1[10]
        g2_out = g2[10] if expanded else g2[tap0] ^ g2[tap1]

        chip.append(g1_out ^ g2_out)

        temp = g1[10] ^ g1[3]
        g1[2:11] = g1[1:10]
        g1[1] = temp

        temp = g2[10] ^ g2[9] ^ g2[8] ^ g2[6] ^ g2[3] ^ g2[2]
        g2[2:11] = g2[1:10]
        g2[1] = temp

    # Convert binary array to number
    result = 0
    for digits in chip:
        result = (result << 1 ) | digits
    
    return oct(result)


# prn_legacy.csv and prn_extended.csv copied from

# IS-GPS-200N, 01-AUG-2022
# Table 3-Ia. Code Phase Assignments
# Table 3-Ib. Expanded Code Phase Assignments

# on pages 6, 7, 8

print("Testing PRN 1-37 (legacy two tap) C/A codes.")

with open('prn_legacy.csv', newline='') as file:
    reader = csv.DictReader(file)

    for row in reader:

        computed = first_ten_octal(0, int(row["tap0"]), int(row["tap1"]), 0)

        if computed[2:] == row["octal"]:
            print(f'Sat {row["prn"]} passed.')
        else:
            print(f'Sat {row["prn"]} failed. Expected {row["octal"]}, computed {computed[2:]}')

print("Testing PRN 37-63 (expanded) C/A codes.")

with open('prn_expanded.csv', newline='') as file:
    reader = csv.DictReader(file)

    for row in reader:
        init = int(row["init"],8)
        computed = first_ten_octal(1, 0, 0, init)

        if computed[2:] == row["octal"]:
            print(f'Sat {row["prn"]} passed.')
        else:
            print(f'Sat {row["prn"]} failed. Expected {row["octal"]}, computed {computed[2:]}')
