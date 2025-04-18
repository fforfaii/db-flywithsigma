id = "68026edd79860dde25e66f2f"
num_seat = 180
nF = 0
nB = 0
a = ["A", "B", "C", "D", "E", "F"]
perrow = 6

with open("out.txt", "w") as f:
    f.write("[\n")
    for i in range(num_seat):
        f.write("\t{\n")

        f.write('\t\t"AircraftId": { "$oid": "')
        f.write(id)
        f.write('" },\n')

        f.write('\t\t"SeatType": "')
        if i < nF:
            f.write("FIRSTCLASS")
        elif i < nF + nB:
            f.write("BUSINESS")
        else:
            f.write("ECONOMY")
        f.write('",\n')

        f.write('\t\t"SeatNo": "')
        f.write(("0" + str(int((i / perrow)) + 1))[-2:])

        f.write(a[i % perrow])
        f.write('"\n')

        f.write("\n\t},\n")

    f.write("\n]")
