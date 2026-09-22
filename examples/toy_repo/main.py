"""Toy CLI entry point: load stock from a file, sell a fixed demo order, report low stock."""

import sys

from inventory import Inventory
from report import format_low_stock

LOW_STOCK_THRESHOLD = 5
DEMO_ORDER = [("widget", 3), ("gadget", 12)]


def main(counts_path):
    shop = Inventory({})
    shop.load_counts_from_file(counts_path)
    for sku, amount in DEMO_ORDER:
        result = shop.sell(sku, amount)
        if result is None:
            print(f"Could not sell {amount} of {sku}: insufficient stock or unknown SKU.")
    print(format_low_stock(shop._counts, LOW_STOCK_THRESHOLD))


if __name__ == "__main__":
    main(sys.argv[1])
