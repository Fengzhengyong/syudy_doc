def addToInventory(inventory, addedItems):
    for k in addedItems:
        inventory.setdefault(k, 0)
        inventory[k]=inventory.get(k)+1
    return inventory


def displayInventory(stuff):
    print('Inventory:')
    total=0
    for k, v in stuff.items():
        print(str(v) +' '+k)
        total+=v
    print('Total number of items: '+str(total))

inv = {'gold coin': 42, 'rope': 1}
dragonLoot = ['gold coin', 'dagger', 'gold coin', 'gold coin', 'ruby']
inv = addToInventory(inv, dragonLoot)
displayInventory(inv)
