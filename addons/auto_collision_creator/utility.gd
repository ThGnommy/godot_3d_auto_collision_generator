class_name ACC_Utility

static func recursive_set_owner(node: Node, new_owner: Node, root: Node):
	if node.owner != root:
		return
	node.set_owner(new_owner)
	for child in node.get_children():
		recursive_set_owner(child, new_owner, root)
