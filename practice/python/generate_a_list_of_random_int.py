# coding: utf-8
import random

def generate_a_list_of_random_int():
    list_of_rand = []
    for i in range(1,11):
        list_of_rand.append(random.randint(0,63))
    reversed_list = list(reversed(list_of_rand))
    result = list_of_rand + reversed_list
    return result

if __name__ == "__main__":
    for i in range(1,21):
        result = generate_a_list_of_random_int()
        print(i, result)
