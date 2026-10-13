#!/bin/bash

# get user input for the ip to calculate for (only if u want to use read input vs cmd line)
#read -p "what is your ip input?" ipInput
#read -p "what is your mask input?" maskInput

ipGet=""
maskGet=""
subID1=0
subID2=0
subID3=0
subID4=0
broadcastAddr1=0
broadcastAddr2=0
broadcastAddr3=0
broadcastAddr4=0
interestingOctet=0
interestingIndex=0

# check if those inputs are even valid
if [[ -z "$1" ]] || [[ -z "$2" ]]; then
        if [[ -z "$ipInput" ]] || [[ -z "$maskInput" ]]; then
            echo "usage: ipAddrCalc <ip addr> <ip mask>"
            exit 1
        else
#           echo "valid input 1"
            ipGet="$ipInput"
            maskGet="$maskInput"
        fi
else
#    echo "valid input 2"
    ipGet="$1"
    maskGet="$2"
fi

# now we calculate subnet ID

# get first part of mask
maskGet1=$(echo "$maskGet" | cut -d. -f1)
maskGet2=$(echo "$maskGet" | cut -d. -f2)
maskGet3=$(echo "$maskGet" | cut -d. -f3)
maskGet4=$(echo "$maskGet" | cut -d. -f4)

# get maskOne
if [[ "$maskGet1" == 255 ]]; then
    subID1=$(echo "$ipGet" | cut -d. -f1)
elif [[ "$maskGet1" == 0 ]]; then
    subID1=0
else
    interestingOctet="$maskGet1"
    interestingIndex=1
    echo "got 1"
fi

# get maskTwo
if [[ "$maskGet2" == 255 ]]; then
    subID2=$(echo "$ipGet" | cut -d. -f2)
elif [[ "$maskGet2" == 0 ]]; then
    subID2=0
else
    interestingOctet="$maskGet2"
    interestingIndex=2
    echo "got 2"
fi

# get maskThree
if [[ "$maskGet3" == 255 ]]; then
    subID3=$(echo "$ipGet" | cut -d. -f3)
elif [[ "$maskGet3" == 0 ]]; then
    subID3=0
else
    interestingOctet="$maskGet3"
    interestingIndex=3
    echo "got 3"
fi

# get maskFour
if [[ "$maskGet4" == 255 ]]; then
    subID4=$(echo "$ipGet" | cut -d. -f4)
elif [[ "$maskGet4" == 0 ]]; then
    subID4=0
else
    interestingOctet="$maskGet4"
    interestingIndex=4
    echo "got 4"
fi

# this is the outlier! the interesting Octet
#echo "interestingOctet: $interestingOctet"

# now lets calculate the magic number value:
if [[ "$interestingOctet" -gt 0 ]]; then
    magicNumber=$((256 - interestingOctet))
else
    magicNumber=256
fi

# now that we have out magic number, lets split
# the 248 into $magicNumber (8) and see how many
# times it goes into it to get our last value
# for the subnet ID (subID)

if [[ "$interestingIndex" -eq 1 ]]; then
    getIP1=$(echo "$ipGet" | cut -d. -f1)
    subID1=$((getIP1 / magicNumber * magicNumber))
elif [[ "$interestingIndex" -eq 2 ]]; then
    getIP2=$(echo "$ipGet" | cut -d. -f2)
    subID2=$((getIP2 / magicNumber * magicNumber))
elif [[ "$interestingIndex" -eq 3 ]]; then
    getIP3=$(echo "$ipGet" | cut -d. -f3)
    subID3=$((getIP3 / magicNumber * magicNumber))
elif [[ "$interestingIndex" -eq 4 ]]; then
    getIP4=$(echo "$ipGet" | cut -d. -f4)
    subID4=$((getIP4 / magicNumber * magicNumber))
fi

# quickly define subnet id
subnetID="$subID1.$subID2.$subID3.$subID4"

echo "mask: $maskGet"
echo "ip: $ipGet"
echo "subnet id: $subnetID"
echo "interesting octet: $interestingOctet"

# now we calculate the broadcast address
# we do not need to define mask get vars to get
# the ip BECAUSE we reuse the mask

# get maskOne
if [[ "$maskGet1" == 255 ]]; then
    broadcastAddr1=$(echo "$subnetID" | cut -d. -f1)
elif [[ "$maskGet1" == 0 ]]; then
    broadcastAddr1=255
else
    broadcastAddr1=$((subID1 + magicNumber - 1))
#   echo "got 1"
fi

# get maskTwo
if [[ "$maskGet2" == 255 ]]; then
    broadcastAddr2=$(echo "$subnetID" | cut -d. -f2)
elif [[ "$maskGet2" == 0 ]]; then
    broadcastAddr2=255
else
    broadcastAddr2=$((subID2 + magicNumber - 1))
#   echo "got 2"
fi

# get maskThree
if [[ "$maskGet3" == 255 ]]; then
    broadcastAddr3=$(echo "$subnetID" | cut -d. -f3)
elif [[ "$maskGet3" == 0 ]]; then
    broadcastAddr3=255
else
    broadcastAddr3=$((subID3 + magicNumber - 1))
#   echo "got 3"
fi

# get maskFour
if [[ "$maskGet4" == 255 ]]; then
    broadcastAddr4=$(echo "$subnetID" | cut -d. -f4)
elif [[ "$maskGet4" == 0 ]]; then
    broadcastAddr4=255
else
    broadcastAddr4=$((subID4 + magicNumber - 1))
#   echo "got 4"
fi

echo "broadcast addr: $broadcastAddr1.$broadcastAddr2.$broadcastAddr3.$broadcastAddr4"

# good job! now lastly we just calculate the first and last ip of the network:
# we just add one to the subnet ID
firstHost4=$((subID4 + 1))

echo "first host: $subID1.$subID2.$subID3.$firstHost4"

# and for the last ip of the network we subtract one fromt he broadcast addr:
lastHost4=$((broadcastAddr4 - 1))

echo "last host: $broadcastAddr1.$broadcastAddr2.$broadcastAddr3.$lastHost4"
