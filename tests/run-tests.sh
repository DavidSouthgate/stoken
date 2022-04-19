#!/bin/bash
dir=$(dirname "$0")
cd "${dir}"

if [[ ! -f ../stoken ]]; then
    printf "\e[41mERROR: Stoken not found\e[0m\n"
    echo "Has the project been built?"
    exit 2
fi

max_name_length=0

for filename in *.pipe; do
    name="${filename%.*}"
    length=${#name}
    if [[ ${length} -gt ${max_name_length} ]]; then
        max_name_length=${length}
    fi
done

pass=0
fail=0
for filename in *.pipe; do
    name="${filename%.*}"
    printf "%-${max_name_length}s" "${name}"
    output=$(./pipe-wrapper.sh "${filename}")
    if [[ $? -eq 0 ]]; then
        pass=$((pass+1))
        printf " \e[42mPASS\e[0m\n"
    else
        fail=$((fail+1))
        printf " \e[41mFAIL\e[0m\n"
        echo "${output}" | sed 's/^/    /'
        echo ""
    fi
done

total=$((pass+fail))

echo ""
echo "Tests run: ${total}, Passed: ${pass}, Failures: ${fail}"

if [[ $fail -eq 0 ]]; then
    printf "\e[42mTESTS PASSED\e[0m\n"
    exit 0
else
    printf "\e[41mTESTS FAILED\e[0m\n"
    exit 1
fi
