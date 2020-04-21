import pprint

def displayInventory(stuff):
    print('Inventory:')
    total=0
    for k, v in stuff.items():
        print(str(v) +' '+k)
        total+=v
    print('Total number of items: '+str(total))

stuff = {'rope': 1, 'torch': 6, 'gold coin': 42, 'dagger': 1, 'arrow': 12}
displayInventory(stuff)
    
