import React, { createContext, useState, useEffect } from 'react';
import { cartAPI } from '../services/api';

export const CartContext = createContext();

export const CartProvider = ({ children }) => {
    const [cart, setCart] = useState({ items: [], total: 0 });
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        const token = localStorage.getItem('token');
        if (token) fetchCart();
    }, []);

    const fetchCart = async () => {
        try {
            setLoading(true);
            const { data } = await cartAPI.get();
            if (data.success) {
                // new_server returns array of cart items on `message`
                const items = (data.message || []).map(item => ({
                    _id: item.cartId,
                    productId: item.productId,
                    name: item.name,
                    image: item.image,
                    price: item.pricePerUnit,
                    qty: item.number,
                    unit: item.unit,
                    type: item.type,
                    brand: item.brandName,
                    product: {
                        _id: item.productId,
                        name: item.name,
                        price: item.pricePerUnit,
                        images: item.image ? [item.image] : [],
                        deliveryType: item.deliveryCategory,
                    }
                }));
                const total = items.reduce((sum, i) => sum + (i.price || 0) * (i.qty || 1), 0);
                setCart({ items, total });
            }
        } catch (error) {
            console.error('Cart fetch skipped:', error?.response?.status);
        } finally {
            setLoading(false);
        }
    };

    const addToCart = async (productId, quantity = 1) => {
        try {
            const { data } = await cartAPI.add(productId, quantity);
            if (data.success) {
                await fetchCart(); // re-fetch to get the populated cart
                return { success: true };
            }
            return { success: false, message: data.message };
        } catch (error) {
            return { success: false, message: error.response?.data?.message || 'Failed to add' };
        }
    };

    const removeFromCart = async (cartItemId) => {
        try {
            await cartAPI.remove(cartItemId);
            await fetchCart();
        } catch (error) {
            console.error('Failed to remove item:', error);
        }
    };

    const clearCart = async () => {
        // Clear all items one by one (no dedicated clear endpoint)
        try {
            for (const item of cart.items) {
                await cartAPI.remove(item.productId || item._id);
            }
            setCart({ items: [], total: 0 });
        } catch (error) {
            console.error('Failed to clear cart:', error);
        }
    };

    return (
        <CartContext.Provider value={{ cart, loading, addToCart, removeFromCart, clearCart, refreshCart: fetchCart }}>
            {children}
        </CartContext.Provider>
    );
};
