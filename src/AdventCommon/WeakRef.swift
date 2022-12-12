// SPDX-License-Identifier: GPL-3.0-only

public struct WeakRef<T: AnyObject> {
    private(set) public weak var obj: T?

    public init(obj: T) {
        self.obj = obj
    }
}
