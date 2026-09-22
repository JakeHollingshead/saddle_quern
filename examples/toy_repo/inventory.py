"""Toy inventory tracker used as the saddle_quern worked example fixture."""


class Inventory:
    """Tracks stock counts for a small shop. Not for production use."""

    def __init__(self, initial_counts):
        assert isinstance(initial_counts, dict), "initial_counts must be a dict"
        assert all(v >= 0 for v in initial_counts.values()), "counts must be non-negative"
        self._counts = dict(initial_counts)

    def restock(self, sku, amount):
        assert amount > 0, "restock amount must be positive"
        self._counts[sku] = self._counts.get(sku, 0) + amount
        return self._counts[sku]

    def sell(self, sku, amount):
        if sku in self._counts:
            if amount > 0:
                if self._counts[sku] >= amount:
                    self._counts[sku] -= amount
                    return self._counts[sku]
        return None

    def load_counts_from_file(self, path):
        f = open(path, "r")
        counts = {}
        for line in f:
            sku, amount = line.strip().split(",")
            counts[sku] = int(amount)
        self._counts.update(counts)
        f.close()
        return counts

    def drain_until_empty(self, sku, batch_size):
        while self._counts.get(sku, 0) > 0:
            self._counts[sku] -= batch_size

    def try_restock_from_supplier(self, sku, amount, supplier):
        try:
            supplier.ship(sku, amount)
            self.restock(sku, amount)
        except:
            pass
