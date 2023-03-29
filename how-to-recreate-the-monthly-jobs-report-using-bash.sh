#!/bin/bash
URL="https://www2.census.gov/programs-surveys/cps/datasets/2023/basic/jan23pub.dat.gz"
FILE="jan23pub.dat"

if [[ ! -f "$FILE" ]]; then
    curl -s "$URL" -o "${FILE}.gz"
    gunzip "${FILE}.gz"
fi

IFS=$'\n' data=( $(<$FILE) )

population=0
laborforce=0
employed=0
unemployed=0
nilf=0
wantjob=0
for line in "${data[@]}"; do
    PEMLR=${line:179:2}
    PWCMPWGT=${line:845:10}
    PRWNTJOB=${line:417:2}

    if ((PEMLR != -1)); then
        ((population+=PWCMPWGT))
    fi

    if ((PEMLR > 0)) && ((PEMLR < 5)); then
        ((laborforce+=PWCMPWGT))
    fi

    if ((PEMLR > 0)) && ((PEMLR < 3)); then
        ((employed+=PWCMPWGT))
    fi

    if ((PEMLR > 2)) && ((PEMLR < 5)); then
        ((unemployed+=PWCMPWGT))
    fi

    if ((PEMLR > 4)) && ((PEMLR < 8)); then
        ((nilf+=PWCMPWGT))
    fi

    if ((PRWNTJOB==1)); then
        ((wantjob+=PWCMPWGT))
    fi
done

((participation=laborforce*1000/population))
((epop=employed*1000/population))
((unrate=unemployed*1000/laborforce))
((population/=10000000))
((laborforce/=10000000))
((employed/=10000000))
((unemployed/=10000000))
((nilf/=10000000))
((wantjob/=10000000))
echo $population
echo $laborforce
echo $participation
echo $employed
echo $epop
echo $unemployed
echo $unrate
echo $nilf
echo $wantjob